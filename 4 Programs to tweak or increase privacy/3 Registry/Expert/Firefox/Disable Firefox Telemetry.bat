@echo off
REM Disable Firefox default browser agent tasks
schtasks.exe /change /disable /tn "\\Mozilla\\Firefox Default Browser Agent 308046B0AF4A39CB"
schtasks.exe /change /disable /tn "\\Mozilla\\Firefox Default Browser Agent D2CEEC440E2074BD"

REM Apply registry tweaks directly
echo Windows Registry Editor Version 5.00 > "%temp%\disable_firefox_telemetry.reg"
echo. >> "%temp%\disable_firefox_telemetry.reg"
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox] >> "%temp%\disable_firefox_telemetry.reg"
echo "DisableTelemetry"=dword:00000001 >> "%temp%\disable_firefox_telemetry.reg"
echo "DisableDefaultBrowserAgent"=dword:00000001 >> "%temp%\disable_firefox_telemetry.reg"

REM Import registry tweaks
regedit.exe /s "%temp%\disable_firefox_telemetry.reg"

REM Clean up
del "%temp%\disable_firefox_telemetry.reg"

REM Notify user
echo Tweaks Applied
pause
