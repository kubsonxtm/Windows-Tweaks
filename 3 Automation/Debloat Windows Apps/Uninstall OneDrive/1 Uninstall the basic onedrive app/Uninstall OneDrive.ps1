Write-Output "Kill OneDrive process"
taskkill.exe /F /IM "OneDrive.exe"
taskkill.exe /F /IM "explorer.exe"

Write-Output "Removing OneDrive"
$uninstallCompleted = $false

if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
    Write-Output "Uninstalling OneDrive from System32"
    & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
    $uninstallCompleted = $true
}

if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
    Write-Output "Uninstalling OneDrive from SysWOW64"
    & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
    $uninstallCompleted = $true
}

if ($uninstallCompleted) {
    Write-Output "Waiting for OneDrive uninstall to complete"
    Start-Sleep -Seconds 10

    Write-Output "Restarting explorer"
    Start-Process "explorer.exe"
    Write-Output "OneDrive has been successfully uninstalled."
} else {
    Write-Output "Restarting explorer"
    Start-Process "explorer.exe"
    Write-Output "OneDrive was not found or was not uninstalled."
}

Read-Host -Prompt "Press Enter to exit"
