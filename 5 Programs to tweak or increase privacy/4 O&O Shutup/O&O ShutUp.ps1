$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    try {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Definition)`"" -Verb RunAs
        exit
    }
    catch {
        Write-Host "Failed to elevate: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        exit 1
    }
}

$ErrorActionPreference = "Stop"

# Paths and URLs
$shutupUrl = "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe"
$cfgUrl = "https://raw.githubusercontent.com/kubsonxtm/Windows-Tweaks/main/5%20Programs%20to%20tweak%20or%20increase%20privacy/4%20O%26O%20Shutup/O%26O%20ShutUp%20settings.cfg"
$tempDir = "$env:TEMP\ShutUp10"
$shutupExePath = "$tempDir\ooshutup10.exe"
$cfgPath = "$tempDir\O&O_ShutUp_settings.cfg"
$modifiedCfgPath = "$tempDir\O&O_ShutUp_settings_modified.cfg"

# Create temp directory
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

# Download O&O ShutUp10
Write-Host "Downloading O&O ShutUp10..."
try {
    Invoke-WebRequest -Uri $shutupUrl -OutFile $shutupExePath -ErrorAction Stop
}
catch {
    Write-Host "Error downloading O&O ShutUp10: $_" -ForegroundColor Red
    exit 1
}

try {
    Invoke-WebRequest -Uri $cfgUrl -OutFile $cfgPath -ErrorAction Stop
    
    $cfgContent = Get-Content -Path $cfgPath -Raw
    
    $silentSettings = @"
[General]
ShowSuccessMessageAfterApplying=0
ShowRecommendations=0
ShowNotifications=0
ShowWarningMessages=0
"@

    if (-not ($cfgContent -match "\[General\]")) {
        $cfgContent = $silentSettings + "`n`n" + $cfgContent
    }
    else {
        $cfgContent = $cfgContent -replace "\[General\]", $silentSettings
    }
    
    $cfgContent | Out-File -FilePath $modifiedCfgPath -Encoding utf8 -Force
}
catch {
    Write-Host "Error configuring silent mode: $_" -ForegroundColor Red
    exit 1
}

# Run O&O ShutUp10 silent
Write-Host "Applying optimizations"
try {
    $process = Start-Process -FilePath $shutupExePath -ArgumentList """$modifiedCfgPath""" -PassThru
    
    Start-Sleep -Seconds 2
    
    if (!$process.HasExited) {
        $process.CloseMainWindow() | Out-Null
        Start-Sleep -Seconds 1
        if (!$process.HasExited) {
            $process | Stop-Process -Force
        }
    }
    
    Write-Host "O&O ShutUp10 Optimized. Closing in 3 seconds..." -ForegroundColor Green
    Start-Sleep -Seconds 3
}
catch {
    Write-Host "Error during optimization: $_" -ForegroundColor Red
    exit 1
}