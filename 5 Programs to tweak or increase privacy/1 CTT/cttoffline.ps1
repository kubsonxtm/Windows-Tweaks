# All credits to ChrisTitusTech https://github.com/ChrisTitusTech/winutil 
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    try {
        Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Definition)`"" -Verb RunAs
    }
    catch {
        Write-Error "Failed to elevate: $($_.Exception.Message)"
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        exit
    }
    exit
}


Write-Host "Chris Titus Offline" -ForegroundColor Red

Write-Host "Delete Temporary Files" -ForegroundColor White
Get-ChildItem -Path "C:\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Temporary files cleanup completed!" -ForegroundColor Green

Write-Host "Disabling Consumer Features..." -ForegroundColor White
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "CloudContent" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord
Write-Host "Consumer features disabled!" -ForegroundColor Green


Write-Host "Disabling Telemetry..." -ForegroundColor White

If ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild).CurrentBuild -lt 22557) {
    $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
    Do { Start-Sleep -Milliseconds 100
        $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
    } Until ($preferences)
    Stop-Process $taskmgr
    $preferences.Preferences[28] = 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
}

Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue
If (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge") { Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Recurse -ErrorAction SilentlyContinue }

$ram = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1kb
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value $ram -Force
$autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") { Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl" }
icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null
Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue | Out-Null


Write-Host "Disabling Activity History..." -ForegroundColor White
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "System" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0 -Type DWord
Write-Host "Activity History disabled!" -ForegroundColor Green


Write-Host "Disabling Explorer Automatic Folder Discovery..." -ForegroundColor White
$bags = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags"
$bagMRU = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU"
Remove-Item -Path $bags -Recurse -Force
Remove-Item -Path $bagMRU -Recurse -Force
$allFolders = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell"
New-Item -Path $allFolders -Force
New-ItemProperty -Path $allFolders -Name "FolderType" -Value "NotSpecified" -PropertyType String -Force
Write-Host "Explorer Automatic Folder Discovery disabled!" -ForegroundColor Green


Write-Host "Disabling GameDVR..." -ForegroundColor White
New-Item -Path "HKCU:\System" -Name "GameConfigStore" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Value 2 -Type DWord
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_EFSEFeatureFlags" -Value 0 -Type DWord
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "GameDVR" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Type DWord
Write-Host "GameDVR disabled!" -ForegroundColor Green

Write-Host "Disabling Hibernation..." -ForegroundColor White
powercfg.exe /hibernate off
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernateEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Value 0 -Type DWord
Write-Host "Hibernation disabled!" -ForegroundColor Green

Write-Host "Disabling HomeGroup..." -ForegroundColor White
Set-Service -Name "HomeGroupListener" -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name "HomeGroupProvider" -StartupType Manual -ErrorAction SilentlyContinue
Write-Host "HomeGroup disabled!" -ForegroundColor Green


Write-Host "Disabling Location Tracking..." -ForegroundColor White
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore" -Name "location" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides" -Name "{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service" -Name "Configuration" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
New-Item -Path "HKLM:\SYSTEM" -Name "Maps" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0
Write-Host "Location Tracking disabled!" -ForegroundColor Green


Write-Host "Disabling Storage Sense..." -ForegroundColor White
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Value 0 -Type DWord -Force
Write-Host "Storage Sense disabled!" -ForegroundColor Green


Write-Host "Disabling Wifi-Sense..." -ForegroundColor White
New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi" -Name "AllowWiFiHotSpotReporting" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi" -Name "AllowAutoConnectToWiFiSenseHotspots" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
Write-Host "Wifi-Sense disabled!" -ForegroundColor Green


Write-Host "Disabling PowerShell 7 Telemetry..." -ForegroundColor White
[Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', '1', 'Machine')
Write-Host "PowerShell 7 Telemetry disabled!" -ForegroundColor Green


Write-Host "Disabling Recall..." -ForegroundColor White
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "WindowsAI" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "AllowRecallEnablement" -Type DWord -Value 0
DISM /Online /Disable-Feature /FeatureName:Recall /Quiet /NoRestart
Write-Host "Recall disabled!" -ForegroundColor Green


Write-Host "Debloating Edge..." -ForegroundColor White
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "CreateDesktopShortcutDefault" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "CreateDesktopShortcutDefault" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "EdgeEnhanceImagesEnabled" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "EdgeEnhanceImagesEnabled" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "PersonalizationReportingEnabled" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "PersonalizationReportingEnabled" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "ShowRecommendationsEnabled" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "ShowRecommendationsEnabled" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "HideFirstRunExperience" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "HideFirstRunExperience" -Type DWord -Value 1
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "UserFeedbackAllowed" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "UserFeedbackAllowed" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "ConfigureDoNotTrack" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "ConfigureDoNotTrack" -Type DWord -Value 1
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "AlternateErrorPagesEnabled" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "AlternateErrorPagesEnabled" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "EdgeCollectionsEnabled" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "EdgeCollectionsEnabled" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "EdgeFollowEnabled" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "EdgeFollowEnabled" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "EdgeShoppingAssistantEnabled" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "EdgeShoppingAssistantEnabled" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "MicrosoftEdgeInsiderPromotionEnabled" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "MicrosoftEdgeInsiderPromotionEnabled" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "ShowMicrosoftRewards" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "ShowMicrosoftRewards" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "WebWidgetAllowed" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "WebWidgetAllowed" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "DiagnosticData" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "DiagnosticData" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "EdgeAssetDeliveryServiceEnabled" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "EdgeAssetDeliveryServiceEnabled" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "CryptoWalletEnabled" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "CryptoWalletEnabled" -Type DWord -Value 0
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "WalletDonationEnabled" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "WalletDonationEnabled" -Type DWord -Value 0
Write-Host "Edge debloated!" -ForegroundColor Green


# Disable IPv6
Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6


# Prefer IPv4 over IPv6
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name "DisabledComponents" -Value 32 -Type DWord -Force


# Disable Background Apps
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force


Write-Host "Disabling Microsoft Copilot..." -ForegroundColor White
New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
New-Item "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1 -Type DWord
Set-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1 -Type DWord
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowCopilotButton" 0 -Type DWord
dism /online /remove-package /package-name:Microsoft.Windows.Copilot /norestart | Out-Null
Write-Host "Microsoft Copilot disabled!" -ForegroundColor Green

Write-Host "Disabling Intel MM (vPro LMS)" -ForegroundColor White
Stop-Service LMS -Force -ErrorAction SilentlyContinue
Set-Service LMS -StartupType Disabled -ErrorAction SilentlyContinue
sc.exe delete LMS | Out-Null
pnputil /delete-driver lms.inf* /uninstall /force | Out-Null
Remove-Item "C:\Program Files*\**\LMS.exe" -Recurse -Force -ErrorAction SilentlyContinue
& icacls "C:\Program Files*\**\LMS.exe" /grant Administrators:F /T /C /Q 2>$null
Write-Host "Intel LMS Disabled" -ForegroundColor Green


# Remove Onedrive
$OneDrivePath = $($env:OneDrive)
Write-Host "Removing OneDrive"
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe"
if (Test-Path $regPath) {
    $OneDriveUninstallString = Get-ItemPropertyValue "$regPath" -Name "UninstallString"
    $OneDriveExe, $OneDriveArgs = $OneDriveUninstallString.Split(" ")
    Start-Process -FilePath $OneDriveExe -ArgumentList "$OneDriveArgs /silent" -NoNewWindow -Wait
} else {
    Write-Host "Onedrive doesn't seem to be installed anymore" -ForegroundColor Red
}
# Check if OneDrive got Uninstalled
if (-not (Test-Path $regPath)) {
    Write-Host "Copy downloaded Files from the OneDrive Folder to Root UserProfile"
    Start-Process -FilePath powershell -ArgumentList "robocopy '$($OneDrivePath)' '$($env:USERPROFILE.TrimEnd())\' /mov /e /xj" -NoNewWindow -Wait

    Write-Host "Removing OneDrive leftovers"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\OneDrive"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:systemdrive\OneDriveTemp"
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\OneDrive" -f
    # check if directory is empty before removing:
    If ((Get-ChildItem "$OneDrivePath" -Recurse | Measure-Object).Count -eq 0) {
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$OneDrivePath"
    }

    Write-Host "Remove Onedrive from explorer sidebar"
    Set-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0
    Set-ItemProperty -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0

    Write-Host "Removing run hook for new users"
    reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
    reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
    reg unload "hku\Default"

    Write-Host "Removing startmenu entry"
    Remove-Item -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

    Write-Host "Removing scheduled task"
    Get-ScheduledTask -TaskPath '\' -TaskName 'OneDrive*' -ea SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

    # Add Shell folders restoring default locations
    Write-Host "Shell Fixing"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "AppData" -Value "$env:userprofile\AppData\Roaming" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Cache" -Value "$env:userprofile\AppData\Local\Microsoft\Windows\INetCache" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Cookies" -Value "$env:userprofile\AppData\Local\Microsoft\Windows\INetCookies" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Favorites" -Value "$env:userprofile\Favorites" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "History" -Value "$env:userprofile\AppData\Local\Microsoft\Windows\History" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Local AppData" -Value "$env:userprofile\AppData\Local" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Music" -Value "$env:userprofile\Music" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Video" -Value "$env:userprofile\Videos" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "NetHood" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Network Shortcuts" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "PrintHood" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Printer Shortcuts" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Programs" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Recent" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Recent" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "SendTo" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\SendTo" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Start Menu" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Startup" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Templates" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Templates" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value "$env:userprofile\Downloads" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Desktop" -Value "$env:userprofile\Desktop" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Pictures" -Value "$env:userprofile\Pictures" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Personal" -Value "$env:userprofile\Documents" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" -Value "$env:userprofile\Documents" -Type ExpandString
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{0DDD015D-B06C-45D5-8C4C-F59713854639}" -Value "$env:userprofile\Pictures" -Type ExpandString
}

# Dark Mode
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 0


# Bing Search
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion" -Name "Search" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0


# Recommendations in Start Menu
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideRecommendedSection" -Value 1 -Type DWord -Force


# Show Hidden Files
Write-Host "Show Hidden Files"
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1


# Show File Extensions
Write-Host "Show File Extensions"
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0


# Detailed BSOD
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "DisplayParameters" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "DisableEmoticon" -Type DWord -Value 1


Write-Host "Setting Services to Manual..." -ForegroundColor White
@("BITS", "DoSvc", "MapsBroker", "WSearch", "sppsvc", "wscsvc") | ForEach-Object {
    $svcName = $_
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$svcName"
    if (Test-Path $regPath) {
        try {
            Set-ItemProperty -Path $regPath -Name "Start" -Value 2 -Type DWord -Force -ErrorAction Stop
            Set-ItemProperty -Path $regPath -Name "DelayedAutostart" -Value 1 -Type DWord -Force -ErrorAction Stop
        } catch {
        }
    }
}

$serviceSettings = @(
    @{Name="AJRouter"; StartupType="Disabled"},
    @{Name="ALG"; StartupType="Manual"},
    @{Name="AppIDSvc"; StartupType="Manual"},
    @{Name="AppMgmt"; StartupType="Manual"},
    @{Name="AppReadiness"; StartupType="Manual"},
    @{Name="AppVClient"; StartupType="Disabled"},
    @{Name="AppXSvc"; StartupType="Manual"},
    @{Name="Appinfo"; StartupType="Manual"},
    @{Name="AssignedAccessManagerSvc"; StartupType="Disabled"},
    @{Name="AudioEndpointBuilder"; StartupType="Automatic"},
    @{Name="AudioSrv"; StartupType="Automatic"},
    @{Name="Audiosrv"; StartupType="Automatic"},
    @{Name="AxInstSV"; StartupType="Manual"},
    @{Name="BDESVC"; StartupType="Manual"},
    @{Name="BFE"; StartupType="Automatic"},
    @{Name="BITS"; StartupType="AutomaticDelayedStart"},
    @{Name="BTAGService"; StartupType="Manual"},
    @{Name="BcastDVRUserService_*"; StartupType="Manual"},
    @{Name="BluetoothUserService_*"; StartupType="Manual"},
    @{Name="BrokerInfrastructure"; StartupType="Automatic"},
    @{Name="Browser"; StartupType="Manual"},
    @{Name="BthAvctpSvc"; StartupType="Automatic"},
    @{Name="BthHFSrv"; StartupType="Automatic"},
    @{Name="CDPSvc"; StartupType="Manual"},
    @{Name="CDPUserSvc_*"; StartupType="Automatic"},
    @{Name="COMSysApp"; StartupType="Manual"},
    @{Name="CaptureService_*"; StartupType="Manual"},
    @{Name="CertPropSvc"; StartupType="Manual"},
    @{Name="ClipSVC"; StartupType="Manual"},
    @{Name="ConsentUxUserSvc_*"; StartupType="Manual"},
    @{Name="CoreMessagingRegistrar"; StartupType="Automatic"},
    @{Name="CredentialEnrollmentManagerUserSvc_*"; StartupType="Manual"},
    @{Name="CryptSvc"; StartupType="Automatic"},
    @{Name="CscService"; StartupType="Manual"},
    @{Name="DPS"; StartupType="Automatic"},
    @{Name="DcomLaunch"; StartupType="Automatic"},
    @{Name="DcpSvc"; StartupType="Manual"},
    @{Name="DevQueryBroker"; StartupType="Manual"},
    @{Name="DeviceAssociationBrokerSvc_*"; StartupType="Manual"},
    @{Name="DeviceAssociationService"; StartupType="Manual"},
    @{Name="DeviceInstall"; StartupType="Manual"},
    @{Name="DevicePickerUserSvc_*"; StartupType="Manual"},
    @{Name="DevicesFlowUserSvc_*"; StartupType="Manual"},
    @{Name="Dhcp"; StartupType="Automatic"},
    @{Name="DiagTrack"; StartupType="Disabled"},
    @{Name="DialogBlockingService"; StartupType="Disabled"},
    @{Name="DispBrokerDesktopSvc"; StartupType="Automatic"},
    @{Name="DisplayEnhancementService"; StartupType="Manual"},
    @{Name="DmEnrollmentSvc"; StartupType="Manual"},
    @{Name="Dnscache"; StartupType="Automatic"},
    @{Name="DoSvc"; StartupType="AutomaticDelayedStart"},
    @{Name="DsSvc"; StartupType="Manual"},
    @{Name="DsmSvc"; StartupType="Manual"},
    @{Name="DusmSvc"; StartupType="Automatic"},
    @{Name="EFS"; StartupType="Manual"},
    @{Name="EapHost"; StartupType="Manual"},
    @{Name="EntAppSvc"; StartupType="Manual"},
    @{Name="EventLog"; StartupType="Automatic"},
    @{Name="EventSystem"; StartupType="Automatic"},
    @{Name="FDResPub"; StartupType="Manual"},
    @{Name="Fax"; StartupType="Manual"},
    @{Name="FontCache"; StartupType="Automatic"},
    @{Name="FrameServer"; StartupType="Manual"},
    @{Name="FrameServerMonitor"; StartupType="Manual"},
    @{Name="GraphicsPerfSvc"; StartupType="Manual"},
    @{Name="HomeGroupListener"; StartupType="Manual"},
    @{Name="HomeGroupProvider"; StartupType="Manual"},
    @{Name="HvHost"; StartupType="Manual"},
    @{Name="IEEtwCollectorService"; StartupType="Manual"},
    @{Name="IKEEXT"; StartupType="Manual"},
    @{Name="InstallService"; StartupType="Manual"},
    @{Name="InventorySvc"; StartupType="Manual"},
    @{Name="IpxlatCfgSvc"; StartupType="Manual"},
    @{Name="KeyIso"; StartupType="Automatic"},
    @{Name="KtmRm"; StartupType="Manual"},
    @{Name="LSM"; StartupType="Automatic"},
    @{Name="LanmanServer"; StartupType="Automatic"},
    @{Name="LanmanWorkstation"; StartupType="Automatic"},
    @{Name="LicenseManager"; StartupType="Manual"},
    @{Name="LxpSvc"; StartupType="Manual"},
    @{Name="MSDTC"; StartupType="Manual"},
    @{Name="MSiSCSI"; StartupType="Manual"},
    @{Name="MapsBroker"; StartupType="AutomaticDelayedStart"},
    @{Name="McpManagementService"; StartupType="Manual"},
    @{Name="MessagingService_*"; StartupType="Manual"},
    @{Name="MicrosoftEdgeElevationService"; StartupType="Manual"},
    @{Name="MixedRealityOpenXRSvc"; StartupType="Manual"},
    @{Name="MpsSvc"; StartupType="Automatic"},
    @{Name="MsKeyboardFilter"; StartupType="Manual"},
    @{Name="NPSMSvc_*"; StartupType="Manual"},
    @{Name="NaturalAuthentication"; StartupType="Manual"},
    @{Name="NcaSvc"; StartupType="Manual"},
    @{Name="NcbService"; StartupType="Manual"},
    @{Name="NcdAutoSetup"; StartupType="Manual"},
    @{Name="NetSetupSvc"; StartupType="Manual"},
    @{Name="NetTcpPortSharing"; StartupType="Disabled"},
    @{Name="Netlogon"; StartupType="Automatic"},
    @{Name="Netman"; StartupType="Manual"},
    @{Name="NgcCtnrSvc"; StartupType="Manual"},
    @{Name="NgcSvc"; StartupType="Manual"},
    @{Name="NlaSvc"; StartupType="Manual"},
    @{Name="OneSyncSvc_*"; StartupType="Automatic"},
    @{Name="P9RdrService_*"; StartupType="Manual"},
    @{Name="PNRPAutoReg"; StartupType="Manual"},
    @{Name="PNRPsvc"; StartupType="Manual"},
    @{Name="PcaSvc"; StartupType="Manual"},
    @{Name="PeerDistSvc"; StartupType="Manual"},
    @{Name="PenService_*"; StartupType="Manual"},
    @{Name="PerfHost"; StartupType="Manual"},
    @{Name="PhoneSvc"; StartupType="Manual"},
    @{Name="PimIndexMaintenanceSvc_*"; StartupType="Manual"},
    @{Name="PlugPlay"; StartupType="Manual"},
    @{Name="PolicyAgent"; StartupType="Manual"},
    @{Name="Power"; StartupType="Automatic"},
    @{Name="PrintNotify"; StartupType="Manual"},
    @{Name="PrintWorkflowUserSvc_*"; StartupType="Manual"},
    @{Name="ProfSvc"; StartupType="Automatic"},
    @{Name="PushToInstall"; StartupType="Manual"},
    @{Name="QWAVE"; StartupType="Manual"},
    @{Name="RasAuto"; StartupType="Manual"},
    @{Name="RasMan"; StartupType="Manual"},
    @{Name="RemoteAccess"; StartupType="Disabled"},
    @{Name="RemoteRegistry"; StartupType="Disabled"},
    @{Name="RetailDemo"; StartupType="Manual"},
    @{Name="RmSvc"; StartupType="Manual"},
    @{Name="RpcEptMapper"; StartupType="Automatic"},
    @{Name="RpcLocator"; StartupType="Manual"},
    @{Name="RpcSs"; StartupType="Automatic"},
    @{Name="SCPolicySvc"; StartupType="Manual"},
    @{Name="SCardSvr"; StartupType="Manual"},
    @{Name="SDRSVC"; StartupType="Manual"},
    @{Name="SEMgrSvc"; StartupType="Manual"},
    @{Name="SENS"; StartupType="Automatic"},
    @{Name="SNMPTRAP"; StartupType="Manual"},
    @{Name="SNMPTrap"; StartupType="Manual"},
    @{Name="SSDPSRV"; StartupType="Manual"},
    @{Name="SamSs"; StartupType="Automatic"},
    @{Name="ScDeviceEnum"; StartupType="Manual"},
    @{Name="Schedule"; StartupType="Automatic"},
    @{Name="SecurityHealthService"; StartupType="Manual"},
    @{Name="Sense"; StartupType="Manual"},
    @{Name="SensorDataService"; StartupType="Manual"},
    @{Name="SensorService"; StartupType="Manual"},
    @{Name="SensrSvc"; StartupType="Manual"},
    @{Name="SessionEnv"; StartupType="Manual"},
    @{Name="SgrmBroker"; StartupType="Automatic"},
    @{Name="SharedAccess"; StartupType="Manual"},
    @{Name="SharedRealitySvc"; StartupType="Manual"},
    @{Name="ShellHWDetection"; StartupType="Automatic"},
    @{Name="SmsRouter"; StartupType="Manual"},
    @{Name="Spooler"; StartupType="Automatic"},
    @{Name="SstpSvc"; StartupType="Manual"},
    @{Name="StateRepository"; StartupType="Manual"},
    @{Name="StiSvc"; StartupType="Manual"},
    @{Name="StorSvc"; StartupType="Manual"},
    @{Name="SysMain"; StartupType="Automatic"},
    @{Name="SystemEventsBroker"; StartupType="Automatic"},
    @{Name="TabletInputService"; StartupType="Manual"},
    @{Name="TapiSrv"; StartupType="Manual"},
    @{Name="TermService"; StartupType="Automatic"},
    @{Name="TextInputManagementService"; StartupType="Manual"},
    @{Name="Themes"; StartupType="Automatic"},
    @{Name="TieringEngineService"; StartupType="Manual"},
    @{Name="TimeBroker"; StartupType="Manual"},
    @{Name="TimeBrokerSvc"; StartupType="Manual"},
    @{Name="TokenBroker"; StartupType="Manual"},
    @{Name="TrkWks"; StartupType="Automatic"},
    @{Name="TroubleshootingSvc"; StartupType="Manual"},
    @{Name="TrustedInstaller"; StartupType="Manual"},
    @{Name="UI0Detect"; StartupType="Manual"},
    @{Name="UdkUserSvc_*"; StartupType="Manual"},
    @{Name="UevAgentService"; StartupType="Disabled"},
    @{Name="UmRdpService"; StartupType="Manual"},
    @{Name="UnistoreSvc_*"; StartupType="Manual"},
    @{Name="UserDataSvc_*"; StartupType="Manual"},
    @{Name="UserManager"; StartupType="Automatic"},
    @{Name="UsoSvc"; StartupType="Manual"},
    @{Name="VGAuthService"; StartupType="Automatic"},
    @{Name="VMTools"; StartupType="Automatic"},
    @{Name="VSS"; StartupType="Manual"},
    @{Name="VacSvc"; StartupType="Manual"},
    @{Name="VaultSvc"; StartupType="Automatic"},
    @{Name="W32Time"; StartupType="Manual"},
    @{Name="WEPHOSTSVC"; StartupType="Manual"},
    @{Name="WFDSConMgrSvc"; StartupType="Manual"},
    @{Name="WMPNetworkSvc"; StartupType="Manual"},
    @{Name="WManSvc"; StartupType="Manual"},
    @{Name="WPDBusEnum"; StartupType="Manual"},
    @{Name="WSService"; StartupType="Manual"},
    @{Name="WSearch"; StartupType="AutomaticDelayedStart"},
    @{Name="WaaSMedicSvc"; StartupType="Manual"},
    @{Name="WalletService"; StartupType="Manual"},
    @{Name="WarpJITSvc"; StartupType="Manual"},
    @{Name="WbioSrvc"; StartupType="Manual"},
    @{Name="Wcmsvc"; StartupType="Automatic"},
    @{Name="WcsPlugInService"; StartupType="Manual"},
    @{Name="WdNisSvc"; StartupType="Manual"},
    @{Name="WdiServiceHost"; StartupType="Manual"},
    @{Name="WdiSystemHost"; StartupType="Manual"},
    @{Name="WebClient"; StartupType="Manual"},
    @{Name="Wecsvc"; StartupType="Manual"},
    @{Name="WerSvc"; StartupType="Manual"},
    @{Name="WiaRpc"; StartupType="Manual"},
    @{Name="WinDefend"; StartupType="Automatic"},
    @{Name="WinHttpAutoProxySvc"; StartupType="Manual"},
    @{Name="WinRM"; StartupType="Manual"},
    @{Name="Winmgmt"; StartupType="Automatic"},
    @{Name="WlanSvc"; StartupType="Automatic"},
    @{Name="WpcMonSvc"; StartupType="Manual"},
    @{Name="WpnService"; StartupType="Manual"},
    @{Name="WpnUserService_*"; StartupType="Automatic"},
    @{Name="XblAuthManager"; StartupType="Manual"},
    @{Name="XblGameSave"; StartupType="Manual"},
    @{Name="XboxGipSvc"; StartupType="Manual"},
    @{Name="XboxNetApiSvc"; StartupType="Manual"},
    @{Name="autotimesvc"; StartupType="Manual"},
    @{Name="bthserv"; StartupType="Manual"},
    @{Name="camsvc"; StartupType="Manual"},
    @{Name="cbdhsvc_*"; StartupType="Manual"},
    @{Name="cloudidsvc"; StartupType="Manual"},
    @{Name="dcsvc"; StartupType="Manual"},
    @{Name="defragsvc"; StartupType="Manual"},
    @{Name="diagnosticshub.standardcollector.service"; StartupType="Manual"},
    @{Name="diagsvc"; StartupType="Manual"},
    @{Name="dmwappushservice"; StartupType="Manual"},
    @{Name="dot3svc"; StartupType="Manual"},
    @{Name="edgeupdate"; StartupType="Manual"},
    @{Name="edgeupdatem"; StartupType="Manual"},
    @{Name="embeddedmode"; StartupType="Manual"},
    @{Name="fdPHost"; StartupType="Manual"},
    @{Name="fhsvc"; StartupType="Manual"},
    @{Name="gpsvc"; StartupType="Automatic"},
    @{Name="hidserv"; StartupType="Manual"},
    @{Name="icssvc"; StartupType="Manual"},
    @{Name="iphlpsvc"; StartupType="Automatic"},
    @{Name="lfsvc"; StartupType="Manual"},
    @{Name="lltdsvc"; StartupType="Manual"},
    @{Name="lmhosts"; StartupType="Manual"},
    @{Name="mpssvc"; StartupType="Automatic"},
    @{Name="msiserver"; StartupType="Manual"},
    @{Name="netprofm"; StartupType="Manual"},
    @{Name="nsi"; StartupType="Automatic"},
    @{Name="p2pimsvc"; StartupType="Manual"},
    @{Name="p2psvc"; StartupType="Manual"},
    @{Name="perceptionsimulation"; StartupType="Manual"},
    @{Name="pla"; StartupType="Manual"},
    @{Name="seclogon"; StartupType="Manual"},
    @{Name="shpamsvc"; StartupType="Disabled"},
    @{Name="smphost"; StartupType="Manual"},
    @{Name="spectrum"; StartupType="Manual"},
    @{Name="sppsvc"; StartupType="AutomaticDelayedStart"},
    @{Name="ssh-agent"; StartupType="Disabled"},
    @{Name="svsvc"; StartupType="Manual"},
    @{Name="swprv"; StartupType="Manual"},
    @{Name="tiledatamodelsvc"; StartupType="Automatic"},
    @{Name="tzautoupdate"; StartupType="Disabled"},
    @{Name="uhssvc"; StartupType="Disabled"},
    @{Name="upnphost"; StartupType="Manual"},
    @{Name="vds"; StartupType="Manual"},
    @{Name="vm3dservice"; StartupType="Manual"},
    @{Name="vmicguestinterface"; StartupType="Manual"},
    @{Name="vmicheartbeat"; StartupType="Manual"},
    @{Name="vmickvpexchange"; StartupType="Manual"},
    @{Name="vmicrdv"; StartupType="Manual"},
    @{Name="vmicshutdown"; StartupType="Manual"},
    @{Name="vmictimesync"; StartupType="Manual"},
    @{Name="vmicvmsession"; StartupType="Manual"},
    @{Name="vmicvss"; StartupType="Manual"},
    @{Name="vmvss"; StartupType="Manual"},
    @{Name="wbengine"; StartupType="Manual"},
    @{Name="wcncsvc"; StartupType="Manual"},
    @{Name="webthreatdefsvc"; StartupType="Manual"},
    @{Name="webthreatdefusersvc_*"; StartupType="Automatic"},
    @{Name="wercplsupport"; StartupType="Manual"},
    @{Name="wisvc"; StartupType="Manual"},
    @{Name="wlidsvc"; StartupType="Manual"},
    @{Name="wlpasvc"; StartupType="Manual"},
    @{Name="wmiApSrv"; StartupType="Manual"},
    @{Name="workfolderssvc"; StartupType="Manual"},
    @{Name="wscsvc"; StartupType="AutomaticDelayedStart"},
    @{Name="wuauserv"; StartupType="Manual"},
    @{Name="wudfsvc"; StartupType="Manual"}
)

foreach ($setting in $serviceSettings) {
    $serviceName = $setting.Name
    $targetType = $setting.StartupType
    
    try {
        if ($serviceName -like "*_*") {
            $baseName = $serviceName -replace '_\*', ''
            $wildcardServices = Get-Service | Where-Object { $_.Name -like "$baseName*" }
            foreach ($svc in $wildcardServices) {
                Write-Host "Setting Service $($svc.Name) to $targetType" -ForegroundColor Cyan
                switch ($targetType) {
                    "Automatic" { Set-Service -Name $svc.Name -StartupType Automatic -ErrorAction SilentlyContinue }
                    "AutomaticDelayedStart" { Set-Service -Name $svc.Name -StartupType Automatic -Delayed -ErrorAction SilentlyContinue }
                    "Manual" { Set-Service -Name $svc.Name -StartupType Manual -ErrorAction SilentlyContinue }
                    "Disabled" { Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue }
                }
            }
        } else {
            Write-Host "Setting Service $serviceName to $targetType" -ForegroundColor Cyan
            switch ($targetType) {
                "Automatic" { Set-Service -Name $serviceName -StartupType Automatic -ErrorAction SilentlyContinue }
                "AutomaticDelayedStart" { Set-Service -Name $serviceName -StartupType Automatic -Delayed -ErrorAction SilentlyContinue }
                "Manual" { Set-Service -Name $serviceName -StartupType Manual -ErrorAction SilentlyContinue }
                "Disabled" { Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue }
            }
        }
    } catch {
        Write-Host "Failed to set $serviceName - Restart PC to make changes" -ForegroundColor Red
    }
}


Write-Host "All tweaks applied successfully!" -ForegroundColor Green
Write-Host "Closing in 3 seconds..."
Start-Sleep -Seconds 3
exit








