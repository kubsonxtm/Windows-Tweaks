@echo off
REM DISABLE NVIDIA TELEMETRY SCHEDULED TASKS
schtasks.exe /change /tn "NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /disable
schtasks.exe /change /tn "NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /disable
schtasks.exe /change /tn "NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /disable

REM DISABLE NVTELEMETRY SERVICE
net stop NvTelemetryContainer >nul 2>&1
sc config NvTelemetryContainer start= disabled
sc stop NvTelemetryContainer >nul 2>&1

REM Get the directory of this script
set "ScriptDir=%~dp0"

REM Apply registry tweaks
echo Applying registry tweaks...
regedit.exe "%ScriptDir%Disable.reg"

REM End script
exit
