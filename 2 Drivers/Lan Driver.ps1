function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "powershell"
    $newProcess.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $newProcess.Verb = "runas"
    [System.Diagnostics.Process]::Start($newProcess)
    exit
}

$motherboard = Get-WmiObject Win32_BaseBoard | Select-Object -ExpandProperty Product

$searchUrl = "https://www.google.com/search?q=$motherboard"
Start-Process $searchUrl
