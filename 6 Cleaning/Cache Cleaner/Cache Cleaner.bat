@echo off
setlocal enabledelayedexpansion

:: Checking if the script is running as administrator
openfiles >nul 2>&1
if '%errorlevel%' NEQ '0' (
    echo Run as admin
    pause
    exit
)

:: Retrieving the name of the currently logged in user
set "username=%username%"

echo.
echo                                                        CLEANING
echo.
echo.

for /r "%temp%" %%f in (*) do (
    echo Removing %%f
    del /f /q "%%f"
)
for /d %%d in ("%temp%\*") do (
    rd /s /q "%%d"
)
mkdir "%temp%"

for /r "C:\Windows\Temp" %%f in (*) do (
    echo Removing %%f
    del /f /q "%%f"
)
for /d %%d in ("C:\Windows\Temp\*") do (
    rd /s /q "%%d"
)
mkdir "C:\Windows\Temp"

takeown /f "%SystemRoot%\Prefetch" /r /d y > NUL 2>&1

icacls "%SystemRoot%\Prefetch" /grant "%username%:(OI)(CI)F" /T /C > NUL 2>&1

for /f "delims=" %%f in ('dir /b /a-d "%SystemRoot%\Prefetch\*"') do (
    echo Removing %%f
    del /f /q "%SystemRoot%\Prefetch\%%f"
)

for /d %%d in ("%SystemRoot%\Prefetch\*") do (
    echo Removing directory %%d
    rd /s /q "%%d"
)

takeown /f "%SystemRoot%\SoftwareDistribution\Download" /r /d y > NUL 2>&1

icacls "%SystemRoot%\SoftwareDistribution\Download" /grant "%username%:(OI)(CI)F" /T /C > NUL 2>&1

for /r "%SystemRoot%\SoftwareDistribution\Download" %%f in (*) do (
    echo Removing %%f
    del /f /q "%%f"
)

for /d %%d in ("%SystemRoot%\SoftwareDistribution\Download\*") do (
    echo Removing directory %%d
    rd /s /q "%%d"
)

takeown /f "%SystemRoot%\LiveKernelReports" /r /d y > NUL 2>&1

icacls "%SystemRoot%\LiveKernelReports" /grant "%username%:(OI)(CI)F" /T /C > NUL 2>&1

for /r "%SystemRoot%\LiveKernelReports" %%f in (*) do (
    echo Removing %%f
    del /f /q "%%f"
)

cleanmgr /sageset:1

start /wait cleanmgr /sagerun:1

echo.
echo Cleanup completed
echo.
echo Press any key to exit...
pause >nul
