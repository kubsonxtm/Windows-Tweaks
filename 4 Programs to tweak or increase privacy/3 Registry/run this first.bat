@echo off
REM DIASBLE FIREFOX DEAFULT BROWSER AGENT
schtasks.exe /change /disable /tn "\Mozilla\Firefox Default Browser Agent 308046B0AF4A39CB"
schtasks.exe /change /disable /tn "\Mozilla\Firefox Default Browser Agent D2CEEC440E2074BD"

REM DISABLE TELEMETRY TASKS FOR NVIDIA
schtasks.exe /change /tn NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /disable
schtasks.exe /change /tn NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /disable
schtasks.exe /change /tn NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /disable

REM NVIDIA TELEMETRY SERVICE DISABLE
net.exe stop NvTelemetryContainer
sc.exe config NvTelemetryContainer start= disabled
sc.exe stop NvTelemetryContainer

REM Get the directory of this script
set "ScriptDir=%~dp0"

REM Apply registry tweaks
echo Applying registry tweaks...
regedit.exe "%ScriptDir%registry.reg"

REM End script
exit
