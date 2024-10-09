# Check if running as Administrator
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

# PowerShell window settings
$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

# Function to download a file from the web with progress bar
function Get-FileFromWeb {
    param (
        [Parameter(Mandatory)][string]$URL,
        [Parameter(Mandatory)][string]$File
    )

    function Show-Progress {
        param (
            [Parameter(Mandatory)][Single]$TotalValue,
            [Parameter(Mandatory)][Single]$CurrentValue,
            [Parameter(Mandatory)][string]$ProgressText,
            [Parameter()][int]$BarSize = 10,
            [Parameter()][switch]$Complete
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
        if ($File -match '^\.\\') {
            $File = Join-Path (Get-Location -PSProvider 'FileSystem') ($File -Split '^\.')[1]
        }
        if ($File -and !(Split-Path $File)) {
            $File = Join-Path (Get-Location -PSProvider 'FileSystem') $File
        }
        if ($File) {
            $fileDirectory = $([System.IO.Path]::GetDirectoryName($File))
            if (!(Test-Path($fileDirectory))) {
                [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null
            }
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
            if ($fullSize -gt 0) {
                Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText "Downloading $($File.Name)"
            }
        } while ($count -gt 0)
    }
    finally {
        $reader.Close()
        $writer.Close()
    }
}

# Function to check if DirectX is installed
function Check-DirectX {
    $directXFilePath = "$env:SystemRoot\System32\d3dx11_43.dll"
    return Test-Path $directXFilePath
}

# Check if DirectX is installed
if (Check-DirectX) {
    $userChoice = [System.Windows.Forms.MessageBox]::Show("DirectX is already installed. Do you want to install it anyway?", "DirectX Installation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    
    if ($userChoice -eq [System.Windows.Forms.DialogResult]::No) {
        Write-Host "Installation cancelled by user."
        Write-Host "Press any key to exit..."
        [System.Console]::ReadKey() | Out-Null
        Exit
    }
}

Write-Host "Installing: Direct X . . ."
# Download DirectX
Get-FileFromWeb -URL "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe" -File "$env:TEMP\DirectX.exe"

# Download 7-Zip
Get-FileFromWeb -URL "https://www.7-zip.org/a/7z2301-x64.exe" -File "$env:TEMP\7-Zip.exe"

# Install 7-Zip
Start-Process -wait "$env:TEMP\7-Zip.exe" /S

# Extract files using 7-Zip
cmd /c "C:\Program Files\7-Zip\7z.exe" x "$env:TEMP\DirectX.exe" -o"$env:TEMP\DirectX" -y | Out-Null

# Install DirectX
Start-Process "$env:TEMP\DirectX\DXSETUP.exe"
