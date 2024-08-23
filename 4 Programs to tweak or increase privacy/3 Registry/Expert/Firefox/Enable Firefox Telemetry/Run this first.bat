@echo off
REM ENABLE FIREFOX DEAFULT BROWSER AGENT
schtasks.exe /change /enable /tn \"\\Mozilla\\Firefox Default Browser Agent 308046B0AF4A39CB\"
schtasks.exe /change /enable /tn \"\\Mozilla\\Firefox Default Browser Agent D2CEEC440E2074BD\"

REM Get the directory of this script
set "ScriptDir=%~dp0"

REM Apply registry tweaks
echo Applying registry tweaks...
regedit.exe "%ScriptDir%Enable.reg"

REM End script
exit
