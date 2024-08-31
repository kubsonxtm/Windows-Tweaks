# Function to check if 7-Zip is installed
function Is-7ZipInstalled {
    $registryKey = 'HKEY_LOCAL_MACHINE\SOFTWARE\7-Zip'
    if (Test-Path $registryKey) {
        return $true
    }

    $potentialPaths = @("C:\Program Files\7-Zip\7zFM.exe", "C:\Program Files (x86)\7-Zip\7zFM.exe")
    foreach ($path in $potentialPaths) {
        if (Test-Path $path) {
            Show-Menu $path
            return $true
        }
    }

    return $false
}

# Function to display the menu
function Show-Menu {
    param (
        [string]$path
    )

    $choice = $null

    while ($choice -ne '2') {
        Write-Host "`nSelect an option:"
        Write-Host "1. Run 7-Zip"
        Write-Host "2. Exit"

        $choice = Read-Host "Enter option number"

        switch ($choice) {
            '1' {
                Write-Host "Running 7-Zip..."
                Start-Process $path -Verb RunAs
                # Close the PowerShell window after running 7-Zip
                Exit
            }
            '2' {
                Write-Host "End of program."
                # Close the PowerShell window
                Exit
            }
            default {
                Write-Host "Incorrect selection. Try again."
            }
        }
    }
}

# Define the URL to download and the path to save the file
$url = "https://github.com/ip7z/7zip/releases/download/24.08/7z2408-x64.exe"
$output = "$env:TEMP\7z2408.exe"

# Checking if 7-Zip is already installed
if (-not (Is-7ZipInstalled)) {
    # Downloading the file
    Write-Host "Downloading the installation file..."
    Invoke-WebRequest -Uri $url -OutFile $output

    # Check if the file was downloaded successfully
    if (Test-Path $output) {
        Write-Host "File downloaded successfully: $output"

        # Run the installer in unattended mode
        Write-Host "Getting started with installation..."
        Start-Process $output -ArgumentList "/S" -Wait

        # Make sure 7-Zip is installed in the default location
        if (Test-Path "C:\Program Files\7-Zip\7zFM.exe") {
            Write-Host "Running 7-Zip as an administrator...."
            Start-Process "C:\Program Files\7-Zip\7zFM.exe" -Verb RunAs

            # Remove the installation file
            Write-Host "Deleting the installation file..."
            Remove-Item $output -ErrorAction SilentlyContinue

            # Close the PowerShell window
            Exit
        } else {
            Write-Host "7-Zip not found in default location. Check the path."
        }
    } else {
        Write-Host "Error downloading file."
    }
}
