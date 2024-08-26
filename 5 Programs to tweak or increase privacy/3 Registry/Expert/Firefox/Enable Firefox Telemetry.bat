@echo off
REM Enable Firefox telemetry and default browser agent tasks

REM Enable Firefox default browser agent tasks
schtasks.exe /change /enable /tn "\\Mozilla\\Firefox Default Browser Agent 308046B0AF4A39CB"
schtasks.exe /change /enable /tn "\\Mozilla\\Firefox Default Browser Agent D2CEEC440E2074BD"

REM Remove registry values
echo Windows Registry Editor Version 5.00 > "%temp%\remove_firefox_telemetry.reg"
echo. >> "%temp%\remove_firefox_telemetry.reg"
echo [-HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox] >> "%temp%\remove_firefox_telemetry.reg"

REM Import registry modifications
regedit.exe /s "%temp%\remove_firefox_telemetry.reg"

REM Clean up
del "%temp%\remove_firefox_telemetry.reg"

REM Notify user
echo Tweaks Applied
pause
