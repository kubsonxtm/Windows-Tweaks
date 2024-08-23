@echo off
REM Disable NVIDIA telemetry scheduled tasks
schtasks.exe /change /tn "NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /disable
schtasks.exe /change /tn "NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /disable
schtasks.exe /change /tn "NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /disable

REM Stop and disable the NvTelemetryContainer service
net stop NvTelemetryContainer >nul 2>&1
sc config NvTelemetryContainer start= disabled
sc stop NvTelemetryContainer >nul 2>&1

REM Apply registry tweaks directly
echo Windows Registry Editor Version 5.00 > "%temp%\disable_nvidia_telemetry.reg"
echo. >> "%temp%\disable_nvidia_telemetry.reg"
echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer] >> "%temp%\disable_nvidia_telemetry.reg"
echo "Start"=dword:00000004 >> "%temp%\disable_nvidia_telemetry.reg"

REM Import registry tweaks
regedit.exe /s "%temp%\disable_nvidia_telemetry.reg"

REM Clean up
del "%temp%\disable_nvidia_telemetry.reg"

REM Notify user
echo Tweaks Applied
pause
