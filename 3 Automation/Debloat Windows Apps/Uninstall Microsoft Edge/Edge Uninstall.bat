@echo off
setlocal enabledelayedexpansion

echo Checking for ExecTI process...
tasklist /FI "IMAGENAME eq ExecTI.exe" | find /I "ExecTI.exe" >nul 2>&1

if '%errorlevel%' == '0' (
    echo ExecTI detected. Running full cleanup...
    goto :fullCleanup
) else (
    echo ExecTI not detected. Removing autostart entries only...
    goto :removeAutostart
)

:removeAutostart
echo Removing Edge autostart entries...
powershell -NoProfile -Command ^
    "$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run';" ^
    "$entries = Get-ItemProperty -Path $registryPath;" ^
    "foreach ($entry in $entries.PSObject.Properties) {" ^
    "    if ($entry.Name -like 'MicrosoftEdgeAutoLaunch_*') {" ^
    "        Remove-ItemProperty -Path $registryPath -Name $entry.Name;" ^
    "        Write-Output ('Removed entry ' + $entry.Name + ' from registry.');" ^
    "    }" ^
    "}" ^
    "Write-Output 'Finished removing autostart entries'"

pause
exit /b

:fullCleanup
echo Closing Edge...
taskkill /f /t /im msedge.exe > nul
taskkill /f /t /im MicrosoftEdgeUpdate.exe > nul
taskkill /f /t /im msedgewebview2.exe > nul

:: Delete Edge registry keys
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge" /f > nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update" /f > nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeWebView" /f > nul
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{9459C573-B17A-45AE-9F64-1857B5D58CEE}" /f > nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate" /f > nul
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{1FD49718-1D00-4B19-AF5F-070AF6D5D54C}" /f > nul
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{1FD49718-1D00-4B19-AF5F-070AF6D5D54C}" /f > nul
reg delete "HKEY_CURRENT_USER\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe" /f > nul
reg delete "HKEY_CURRENT_USER\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.MicrosoftEdgeDevToolsClient_8wekyb3d8bbwe" /f > nul

:: Delete Edge scheduled tasks
schtasks /delete /tn "MicrosoftEdgeUpdateTaskMachineUA" /f > nul 2>&1
schtasks /delete /tn "MicrosoftEdgeUpdateTaskMachineCore" /f > nul 2>&1

:: Stop and delete Edge services
net stop MicrosoftEdgeElevationService > nul
sc delete MicrosoftEdgeElevationService > nul
net stop edgeupdate > nul
sc delete edgeupdate > nul
net stop edgeupdatem > nul
sc delete edgeupdatem > nul

:: Remove Edge-related directories and shortcuts
rd /s /q "%ProgramData%\Microsoft\EdgeUpdate" > nul
rd /s /q "%ProgramFiles(x86)%\Microsoft\Edge" > nul
rd /s /q "%ProgramFiles(x86)%\Microsoft\EdgeCore" > nul
rd /s /q "%ProgramFiles(x86)%\Microsoft\EdgeUpdate" > nul
rd /s /q "%ProgramFiles(x86)%\Microsoft\EdgeWebView" > nul
rd /s /q "%ProgramFiles(x86)%\Microsoft\Temp" > nul
del /f /q "%userprofile%\Desktop\Microsoft Edge.lnk" > nul
del /f /q "%systemdrive%\Users\Public\Desktop\Microsoft Edge.lnk" > nul
del /f /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" > nul
del /f /q "%appdata%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" > nul
del /f /q "%appdata%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk" > nul
reg add "HKLM\Software\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d 1 /f > nul
reg add "HKLM\Software\WOW6432Node\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d 1 /f

:: Remove Edge-related tasks
for /f "delims=" %%f in ('dir /s /b %SystemRoot%\System32\Tasks\*MicrosoftEdge*') do (
    takeown /f "%%f"
    icacls "%%f" /grant everyone:F
    del /f /q "%%f"
)

:: Remove Edge AppxPackages
for /f "delims=" %%a in ('powershell -NoProfile -Command "Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -like '*microsoftedge*' } | Select-Object -ExpandProperty PackageFullName"') do (
    if not "%%a"=="" (
        set "APP=%%a"
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\!USER_SID!\!APP!" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\!APP!" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\!APP!" /f >nul 2>&1
        powershell -Command "Remove-AppxPackage -Package '!APP!'" 2>nul
        powershell -Command "Remove-AppxPackage -Package '!APP!' -AllUsers" 2>nul
    )
)

:: Remove SystemApps Microsoft Edge components
for /f "delims=" %%f in ('dir /s /b %SystemRoot%\SystemApps\Microsoft.MicrosoftEdge*') do (
    takeown /f "%%f"
    icacls "%%f" /grant everyone:F
    del /f /q "%%f"
)

:: Remove System32 Microsoft Edge executables
for /f "delims=" %%f in ('dir /s /b %SystemRoot%\System32\MicrosoftEdge*.exe') do (
    takeown /f "%%f"
    icacls "%%f" /grant everyone:F
    del /f /q "%%f"
)

:: Remove SysWOW64 Microsoft Edge executables
for /f "delims=" %%f in ('dir /s /b %SystemRoot%\SysWOW64\MicrosoftEdge*.exe') do (
    takeown /f "%%f"
    icacls "%%f" /grant everyone:F
    del /f /q "%%f"
)

:: Remove Microsoft Edge Stable folder regardless of version
set "basePath=C:\Program Files\WindowsApps"
set "pattern=Microsoft.MicrosoftEdge.Stable_*_neutral__*"

for /d %%D in ("%basePath%\%pattern%") do (
    set "folderPath=%%D"
)

if exist "%folderPath%" (
    echo Folder Microsoft Edge Stable found: %folderPath%
    echo Granting permissions and removing...

    :: Grant permissions to the folder
    takeown /f "%folderPath%" /r /d y > nul 2>&1
    icacls "%folderPath%" /grant %username%:F /t > nul 2>&1

    :: Remove the folder
    rmdir /s /q "%folderPath%"
    if %errorlevel% EQU 0 (
        echo Folder Microsoft Edge Stable was successfully removed.
    ) else (
        echo There was a problem removing the Microsoft Edge Stable folder.
    )
) else (
    echo Microsoft Edge Stable folder not found in %basePath%.
)

:: Remove remaining files in System32
if exist "C:\Windows\System32\MicrosoftEdgeCP.exe" (
    for /f "delims=" %%a in ('dir /b "C:\Windows\System32\MicrosoftEdge*"') do (
        takeown /f "C:\Windows\System32\%%a" > NUL 2>&1
        icacls "C:\Windows\System32\%%a" /inheritance:e /grant "%UserName%:(OI)(CI)F" /T /C > NUL 2>&1
        del /S /Q "C:\Windows\System32\%%a" > NUL 2>&1
    )
)

:: Remove remaining registry entries
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Clients\StartMenuInternet\Microsoft Edge" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\RegisteredApplications" /v "Microsoft Edge" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Clients\StartMenuInternet\Microsoft Edge" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\RegisteredApplications" /v "Microsoft Edge" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.htm\OpenWithProgIds" /v "MSEdgeHTM" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.html\OpenWithProgIds" /v "MSEdgeHTM" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.mht\OpenWithProgIds" /v "MSEdgeMHT" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.mhtml\OpenWithProgIds" /v "MSEdgeMHT" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.pdf\OpenWithProgIds" /v "MSEdgePDF" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.shtml\OpenWithProgIds" /v "MSEdgeHTM" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.svg\OpenWithProgIds" /v "MSEdgeHTM" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.webp\OpenWithProgIds" /v "MSEdgeHTM" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.xht\OpenWithProgIds" /v "MSEdgeHTM" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.xhtml\OpenWithProgIds" /v "MSEdgeHTM" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.xml\OpenWithProgIds" /v "MSEdgeHTM" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Edge" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Edge" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\EdgeIntegration" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\EdgeIntegration" /f

echo Closing ExecTI process...
taskkill /f /t /im ExecTI.exe > nul 2>&1

echo Microsoft Edge should be now uninstalled.

pause
exit /b
