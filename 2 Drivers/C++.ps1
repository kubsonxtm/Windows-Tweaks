If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

$Host.UI.RawUI.WindowTitle = "Visual C++ Installer"
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

function Get-FileFromWeb {
    param ([string]$URL, [string]$File)
    
    $processName = [System.IO.Path]::GetFileNameWithoutExtension($File)
    Get-Process $processName -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    function Show-Progress {
        param ($TotalValue, $CurrentValue, $ProgressText)
        $percent = $CurrentValue / $TotalValue
        $percentComplete = $percent * 100
        Write-Host -NoNewLine "`r$ProgressText $(''.PadRight(10 * $percent, [char]9608).PadRight(10, [char]9617)) $($percentComplete.ToString('##0.00').PadLeft(6)) % " 
    }

    try {
        $request = [System.Net.HttpWebRequest]::Create($URL)
        $response = $request.GetResponse()
        [long]$fullSize = $response.ContentLength
        [byte[]]$buffer = new-object byte[] 1048576
        [long]$total = 0
        $reader = $response.GetResponseStream()
        $writer = new-object System.IO.FileStream $File, 'Create', 'Write', 'None'
        do {
            $count = $reader.Read($buffer, 0, $buffer.Length)
            $writer.Write($buffer, 0, $count)
            $total += $count
            if ($fullSize -gt 0) { Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " Downloading..." }
        } while ($count -gt 0)
        Write-Host "" 
    } finally {
        if ($writer) { $writer.Close(); $writer.Dispose() }
        if ($reader) { $reader.Close(); $reader.Dispose() }
    }
}

function Is-VCRedistInstalled {
    param ([string]$version)
    if ($version -eq "2015_2017_2019_2022") {
        return (Test-Path "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64")
    } else {
        $searchName = "*Visual C++*$version*"
        return (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like $searchName }) -ne $null
    }
}

function Install-VCRedist {
    param ($urlX86, $urlX64, $name)
    Write-Host "Updating Visual C++ ${name}..." -ForegroundColor Cyan
    
    $args = if ($name -eq "2005" -or $name -eq "2008") { "/q" } else { "/install", "/quiet", "/norestart" }
    
    $fileX86 = "$env:TEMP\vcredist_${name}_x86.exe"
    $fileX64 = "$env:TEMP\vcredist_${name}_x64.exe"

    Get-FileFromWeb -URL $urlX86 -File $fileX86
    Start-Process -Wait -FilePath $fileX86 -ArgumentList $args
    
    Get-FileFromWeb -URL $urlX64 -File $fileX64
    Start-Process -Wait -FilePath $fileX64 -ArgumentList $args
    
    Write-Host "Visual C++ ${name}: INSTALLED" -ForegroundColor Green
}

$vcredistList = @(
    @{version = "2005"; urlX86 = "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE"; urlX64 = "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE"},
    @{version = "2008"; urlX86 = "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe"; urlX64 = "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe"},
    @{version = "2010"; urlX86 = "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe"; urlX64 = "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe"},
    @{version = "2012"; urlX86 = "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe"; urlX64 = "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe"},
    @{version = "2013"; urlX86 = "https://aka.ms/highdpimfc2013x86enu"; urlX64 = "https://aka.ms/highdpimfc2013x64enu"},
    @{version = "2015_2017_2019_2022"; urlX86 = "https://aka.ms/vs/17/release/vc_redist.x86.exe"; urlX64 = "https://aka.ms/vs/17/release/vc_redist.x64.exe"}
)

foreach ($vcredist in $vcredistList) {
    if (Is-VCRedistInstalled $vcredist.version) {
        Write-Host "Visual C++ $($vcredist.version): INSTALLED" -ForegroundColor Green
    } else {
        Install-VCRedist -urlX86 $vcredist.urlX86 -urlX64 $vcredist.urlX64 -name $vcredist.version
    }
}

try { Remove-Item "$env:TEMP\vcredist_*" -Force -ErrorAction SilentlyContinue } catch {}

Write-Host "`nAll installed!" -ForegroundColor Green
for ($i = 5; $i -gt 0; $i--) {
    Write-Host -NoNewLine "`rClosing in $i... "
    Start-Sleep -Seconds 1
}
Exit
