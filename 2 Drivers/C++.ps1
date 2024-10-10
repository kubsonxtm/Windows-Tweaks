If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

function Get-FileFromWeb {
    param ([Parameter(Mandatory)][string]$URL, [Parameter(Mandatory)][string]$File)

    function Show-Progress {
        param (
            [Parameter(Mandatory)][Single]$TotalValue, 
            [Parameter(Mandatory)][Single]$CurrentValue, 
            [Parameter(Mandatory)][string]$ProgressText, 
            [Parameter()][int]$BarSize = 10
        )
        
        $percent = $CurrentValue / $TotalValue
        $percentComplete = $percent * 100
        if ($psISE) { 
            Write-Progress "$ProgressText" -id 0 -percentComplete $percentComplete 
        } else { 
            Write-Host -NoNewLine "`r$ProgressText $(''.PadRight($BarSize * $percent, [char]9608).PadRight($BarSize, [char]9617)) $($percentComplete.ToString('##0.00').PadLeft(6)) % " 
        }
    }

    try {
        $request = [System.Net.HttpWebRequest]::Create($URL)
        $response = $request.GetResponse()
        if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) {
            throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'."
        }
        [long]$fullSize = $response.ContentLength
        [byte[]]$buffer = new-object byte[] 1048576
        [long]$total = [long]$count = 0
        $reader = $response.GetResponseStream()
        $writer = new-object System.IO.FileStream $File, 'Create'
        do {
            $count = $reader.Read($buffer, 0, $buffer.Length)
            $writer.Write($buffer, 0, $count)
            $total += $count
            if ($fullSize -gt 0) { Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " $($File.Name)" }
        } while ($count -gt 0)
    }
    finally {
        $reader.Close()
        $writer.Close()
    }
}

function Is-VCRedistInstalled {
    param (
        [string]$version
    )

    if ($version -eq "2015_2017_2019_2022") {
        $x86Key = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x86"
        $x64Key = "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64"

        $x86Installed = Test-Path $x86Key
        $x64Installed = Test-Path $x64Key

        if ($x86Installed -and $x64Installed) {
            return $true
        } else {
            return $false
        }
    } else {
        $installedApps = Get-WmiObject -Class Win32_Product | Where-Object {
            $_.Name -like "*Visual C++*" -and $_.Name -like "*$version*"
        }

        return $installedApps -ne $null
    }
}

function Install-VCRedist {
    param (
        [string]$urlX86,
        [string]$urlX64,
        [string]$name
    )

    Write-Host "Downloading and installing Visual C++ Redistributable $name..."
    
    Get-FileFromWeb -URL $urlX86 -File "$env:TEMP\vcredist_${name}_x86.exe"
    Start-Process -wait "$env:TEMP\vcredist_${name}_x86.exe" -ArgumentList "/q"
    
    Get-FileFromWeb -URL $urlX64 -File "$env:TEMP\vcredist_${name}_x64.exe"
    Start-Process -wait "$env:TEMP\vcredist_${name}_x64.exe" -ArgumentList "/q"
    
    Write-Host "Installation successful for Visual C++ Redistributable $name."
}

$vcredistList = @(
    @{version = "2005"; urlX86 = "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE"; urlX64 = "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE"},
    @{version = "2008"; urlX86 = "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe"; urlX64 = "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe"},
    @{version = "2010"; urlX86 = "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe"; urlX64 = "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe"},
    @{version = "2012"; urlX86 = "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe"; urlX64 = "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe"},
    @{version = "2013"; urlX86 = "https://aka.ms/highdpimfc2013x86enu"; urlX64 = "https://aka.ms/highdpimfc2013x64enu"},
    @{version = "2015_2017_2019_2022"; urlX86 = "https://aka.ms/vs/17/release/vc_redist.x86.exe"; urlX64 = "https://aka.ms/vs/17/release/vc_redist.x64.exe"}
)

$installNeeded = $false
foreach ($vcredist in $vcredistList) {
    if (Is-VCRedistInstalled $vcredist.version) {
        Write-Host "Visual C++ Redistributable $($vcredist.version) is already installed."
    } else {
        Write-Host "Visual C++ Redistributable $($vcredist.version) is NOT installed. Downloading and installing..."
        Install-VCRedist $vcredist.urlX86 $vcredist.urlX64 $vcredist.version
        $installNeeded = $true
    }
}

Write-Host "`nAll checks completed. Select an option:"
Write-Host "1. Reinstall all Visual C++ Redistributables anyway"
Write-Host "2. Exit"
$response = Read-Host "Enter your choice (1 or 2)"

if ($response -eq '1') {
    foreach ($vcredist in $vcredistList) {
        Install-VCRedist $vcredist.urlX86 $vcredist.urlX64 $vcredist.version
    }
    Write-Host "All Visual C++ Redistributables have been reinstalled."
    Write-Host "Press any key to exit..."
    [void][System.Console]::ReadKey($true)

    try {
        Remove-Item "$env:TEMP\vcredist_*" -Force -ErrorAction Stop
    } catch {
    }
    
} else {
    try {
        Remove-Item "$env:TEMP\vcredist_*" -Force -ErrorAction Stop
    } catch {
    }
    Exit
}
