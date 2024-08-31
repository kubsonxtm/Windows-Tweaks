@echo off
:: Check if the script is run as administrator
openfiles >nul 2>&1
if '%errorlevel%' == '0' goto :admin

echo Running the script as administrator...
powershell -Command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs"
exit /b

:admin
echo Edge was found!
echo Edge Closing...
taskkill /f /t /im msedge.exe > nul
taskkill /f /t /im MicrosoftEdgeUpdate.exe > nul
taskkill /f /t /im msedgewebview2.exe > nul
echo Uninstalling Edge...
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge" /f > nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update" /f > nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeWebView" /f > nul
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{9459C573-B17A-45AE-9F64-1857B5D58CEE}" /f > nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate" /f > nul
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{1FD49718-1D00-4B19-AF5F-070AF6D5D54C}" /f > nul
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{1FD49718-1D00-4B19-AF5F-070AF6D5D54C}" /f > nul
schtasks /delete /tn "MicrosoftEdgeUpdateTaskMachineUA" /f > nul 2>&1
schtasks /delete /tn "MicrosoftEdgeUpdateTaskMachineCore" /f > nul 2>&1
net stop MicrosoftEdgeElevationService > nul
sc delete MicrosoftEdgeElevationService > nul
net stop edgeupdate > nul
sc delete edgeupdate > nul
net stop edgeupdatem > nul
sc delete edgeupdatem > nul
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

for /f "delims=" %%f in ('dir /s /b %SystemRoot%\System32\Tasks\*MicrosoftEdge*') do (
    takeown /f "%%f"
    icacls "%%f" /grant everyone:F
    del /f /q "%%f"
)

for /f "delims=" %%a in ('powershell "(New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value"') do set "USER_SID=%%a"

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

for /f "delims=" %%f in ('dir /s /b %SystemRoot%\SystemApps\Microsoft.MicrosoftEdge*') do (
    takeown /f "%%f"
    icacls "%%f" /grant everyone:F
    del /f /q "%%f"
)

for /f "delims=" %%f in ('dir /s /b %SystemRoot%\System32\MicrosoftEdge*.exe') do (
    takeown /f "%%f"
    icacls "%%f" /grant everyone:F
    del /f /q "%%f"
)

for /f "delims=" %%f in ('dir /s /b %SystemRoot%\SysWOW64\MicrosoftEdge*.exe') do (
    takeown /f "%%f"
    icacls "%%f" /grant everyone:F
    del /f /q "%%f"
)

:: Remove files from System32
if exist "C:\Windows\System32\MicrosoftEdgeCP.exe" (
    for /f "delims=" %%a in ('dir /b "C:\Windows\System32\MicrosoftEdge*"') do (
        takeown /f "C:\Windows\System32\%%a" > NUL 2>&1
        icacls "C:\Windows\System32\%%a" /inheritance:e /grant "%UserName%:(OI)(CI)F" /T /C > NUL 2>&1
        del /S /Q "C:\Windows\System32\%%a" > NUL 2>&1
    )
)

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

echo Microsoft Edge should be now uninstalled.
echo Please reboot Windows.
pause
goto :eof
