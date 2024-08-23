@echo off
REM ENABLE NVIDIA TELEMETRY SCHEDULED TASKS
schtasks.exe /change /tn "NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /enable
schtasks.exe /change /tn "NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /enable
schtasks.exe /change /tn "NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /enable

REM ENABLE NVTELEMETRY SERVICE
sc config NvTelemetryContainer start= auto
net start NvTelemetryContainer >nul 2>&1
sc start NvTelemetryContainer >nul 2>&1

REM Apply registry tweaks directly
echo Windows Registry Editor Version 5.00 > "%temp%\enable_nvidia_telemetry.reg"
echo. >> "%temp%\enable_nvidia_telemetry.reg"
echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer] >> "%temp%\enable_nvidia_telemetry.reg"
echo "Start"=dword:00000002 >> "%temp%\enable_nvidia_telemetry.reg"

REM Import registry tweaks
regedit.exe /s "%temp%\enable_nvidia_telemetry.reg"

REM Clean up
del "%temp%\enable_nvidia_telemetry.reg"

REM Notify user
echo Tweaks Applied
pause
