@echo off
setlocal enabledelayedexpansion

echo.
echo                                                        CLEANING
echo.
echo.

rem Windows Error Reporting
for %%k in (
    "HKCU\Software\Microsoft\Windows\Windows Error Reporting"
    "HKLM\Software\Microsoft\Windows\Windows Error Reporting\FullLiveKernelReports\win32k.sys"
    "HKLM\Software\Microsoft\Windows\Windows Error Reporting\LiveKernelReports\win32k.sys"
    "HKLM\Software\Microsoft\Windows\Windows Error Reporting\LocalDumps"
) do (
    echo Deleting registry key: %%k
    reg delete "%%k" /f 2>nul
)

for %%d in (
    "%LocalAppData%\PCHealth\ErrorRep\QSignoff\*.*"
    "%WinDir%\pchealth\ERRORREP"
    "%WinDir%\pchealth\helpctr\DataColl\*.xml"
    "%WinDir%\pchealth\helpctr\OfflineCache"
    "%WinDir%\System32\config\systemprofile\AppData\Local\CrashDumps\*.dmp"
    "%WinDir%\System32\config\systemprofile\Local Settings\Application Data\CrashDumps\*.dmp"
    "%WinDir%\SysWOW64\config\systemprofile\AppData\Local\CrashDumps\*.dmp"
    "%WinDir%\SysWOW64\config\systemprofile\Local Settings\Application Data\CrashDumps\*.dmp"
    "%AllUsersProfile%\Microsoft\Windows\WER\ReportQueue"
) do (
    echo Deleting file or directory: %%d
    if exist "%%d" (
        if exist "%%d\*" (
            rd /s /q "%%d" 2>nul
            echo Deleted directory: %%d
        ) else (
            del /q "%%d" 2>nul
            echo Deleted file: %%d
        )
    )
)

echo.
echo Microsoft Edge Cache
echo.

taskkill /f /im msedge.exe >nul 2>&1

for %%d in (
    "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache"
    "%LocalAppData%\Microsoft\Edge\User Data\Default\Media Cache"
    "%LocalAppData%\Microsoft\Edge\User Data\Default\GPUCache"
    "%LocalAppData%\Microsoft\Edge\User Data\Default\Storage\ext"
    "%LocalAppData%\Microsoft\Edge\User Data\Default\Service Worker"
    "%LocalAppData%\Microsoft\Edge\User Data\ShaderCache"
    "%LocalAppData%\Microsoft\Edge SxS\User Data\Default\Cache"
    "%LocalAppData%\Microsoft\Edge SxS\User Data\Default\Media Cache"
    "%LocalAppData%\Microsoft\Edge SxS\User Data\Default\GPUCache"
    "%LocalAppData%\Microsoft\Edge SxS\User Data\Default\Storage\ext"
    "%LocalAppData%\Microsoft\Edge SxS\User Data\Default\Service Worker"
    "%LocalAppData%\Microsoft\Edge SxS\User Data\ShaderCache"
) do (
    echo Deleting cache or related directory: %%d
    if exist "%%d" (
        rd /s /q "%%d" 2>nul
        echo Deleted directory: %%d
    ) else (
        echo [!] Directory not found: %%d
    )
)

echo.
echo Cleaning Chrome temporary files
echo.

set "chrome_cache=%LOCALAPPDATA%\Google\Chrome\User Data\Default"
echo [+] Cleaning Chrome cache in "%chrome_cache%"

if exist "%chrome_cache%\Cache" (
    echo [+] Deleting Chrome Cache...
    del /q /f /s "%chrome_cache%\Cache\*" >nul
    rd /s /q "%chrome_cache%\Cache" >nul
    echo Deleted Chrome Cache
) else (
    echo [!] Directory not found: "%chrome_cache%\Cache"
)

if exist "%chrome_cache%\Code Cache" (
    echo [+] Deleting Chrome Code Cache...
    del /q /f /s "%chrome_cache%\Code Cache\*" >nul
    rd /s /q "%chrome_cache%\Code Cache" >nul
    echo Deleted Chrome Code Cache
) else (
    echo [!] Directory not found: "%chrome_cache%\Code Cache"
)

if exist "%chrome_cache%\GPUCache" (
    echo [+] Deleting Chrome GPU Cache...
    del /q /f /s "%chrome_cache%\GPUCache\*" >nul
    rd /s /q "%chrome_cache%\GPUCache" >nul
    echo Deleted Chrome GPU Cache
) else (
    echo [!] Directory not found: "%chrome_cache%\GPUCache"
)

echo.
echo Firefox Cache
echo.

taskkill /f /im firefox.exe >nul 2>&1

for %%d in (
    "%LocalAppData%\Mozilla\Firefox\Profiles\*.default-release\cache2\entries"
    "%LocalAppData%\Mozilla\Firefox\Profiles\*.default-release\jumpListCache"
    "%LocalAppData%\Mozilla\Firefox\Profiles\*.default-release\thumbnails"
    "%LocalAppData%\Mozilla\Firefox\Profiles\*.default-release\startupCache"
) do (
    echo Deleting cache or related directory: %%d
    if exist "%%d" (
        rd /s /q "%%d" 2>nul
    )
)

echo.
echo Logs Cleaning
echo.

for %%f in (
    "%SystemDrive%\*.log"
    "%WinDir%\Directx.log"
    "%WinDir%\SchedLgU.txt"
    "%WinDir%\*.log"
    "%WinDir%\security\logs\*.old"
    "%WinDir%\security\logs\*.log"
    "%WinDir%\Debug\*.log"
    "%WinDir%\Debug\UserMode\*.bak"
    "%WinDir%\Debug\UserMode\*.log"
    "%WinDir%\*.bak"
    "%WinDir%\system32\wbem\Logs\*.log"
    "%WinDir%\OEWABLog.txt"
    "%WinDir%\setuplog.txt"
    "%WinDir%\Logs\DISM\*.log"
    "%WinDir%\*.log.txt"
    "%WinDir%\APPLOG\*.*"
    "%WinDir%\system32\wbem\Logs\*.log"
    "%WinDir%\system32\wbem\Logs\*.lo_"
    "%WinDir%\Logs\DPX\*.log"
    "%WinDir%\ServiceProfiles\NetworkService\AppData\Local\Temp\*.log"
    "%WinDir%\Logs\*.log"
    "%LocalAppData%\Microsoft\Windows\WindowsUpdate.log"
    "%LocalAppData%\Microsoft\Windows\WebCache\*.log"
    "%WinDir%\Panther\cbs.log"
    "%WinDir%\Panther\DDACLSys.log"
    "%WinDir%\repair\setup.log"
    "%WinDir%\Panther\UnattendGC\diagerr.xml"
    "%WinDir%\Panther\UnattendGC\diagwrn.xml"
    "%WinDir%\inf\setupapi.offline.log"
    "%WinDir%\inf\setupapi.app.log"
    "%AllUsersProfile%\Microsoft\Network\Downloader\*.*"
    "%AllUsersProfile%\Microsoft\Windows Security Health\Logs\*.*"
    "%WinDir%\System32\WDI\LogFiles\StartupInfo\*.*"
    "%AllUsersProfile%\USOShared\Logs\*.*"
    "%LocalAppData%\ConnectedDevicesPlatform\*.*"
    "%LocalAppData%\Diagnostics\*.*"
    "%ProgramFiles%\UNP\Logs\*.*"
    "%SystemDrive%\PerfLogs\System\Diagnostics\*.*"
    "%SystemDrive%\PerfLogs\System\Performance\*.*"
    "%WinDir%\debug\WIA\*.log"
    "%SystemDrive%\PerfLogs\System\Diagnostics\*.*"
    "%WinDir%\Logs\CBS\*.cab"
    "%WinDir%\Logs\dosvc\*.*"
    "%WinDir%\Logs\NetSetup\*.*"
    "%WinDir%\Logs\CBS\*.cab"
    "%WinDir%\Logs\SIH\*.*"
    "%WinDir%\Logs\WindowsBackup\*.etl"
    "%WinDir%\Panther\FastCleanup\*.log"
    "%WinDir%\Panther\Rollback\*.txt"
    "%WinDir%\security\logs\*.*"
    "%WinDir%\System32\LogFiles\HTTPERR\*.*"
    "%WinDir%\System32\LogFiles\Scm\*.*"
    "%WinDir%\System32\LogFiles\setupcln\*.*"
    "%WinDir%\System32\LogFiles\WMI\*.*"
    "%WinDir%\SysNative\SleepStudy\*.etl"
    "%WinDir%\SysNative\SleepStudy\ScreenOn\*.etl"
    "%WinDir%\System32\SleepStudy\*.etl"
    "%WinDir%\System32\SleepStudy\ScreenOn\*.etl"
) do (
    echo Deleting file or directory: %%f
    if exist "%%f" (
        if exist "%%f\*" (
            rd /s /q "%%f" 2>nul
        ) else (
            del /q "%%f" 2>nul
        )
    )
)

rem Remove additional registry keys
for %%r in (
    "HKLM\Software\Microsoft\RADAR\HeapLeakDetection\DiagnosedApplications"
    "HKLM\Software\Microsoft\Tracing"
    "HKLM\Software\Wow6432Node\Microsoft\RADAR\HeapLeakDetection\DiagnosedApplications"
    "HKLM\Software\Wow6432Node\Microsoft\Tracing"
) do (
    echo Deleting registry key: %%r
    reg delete "%%r" /f 2>nul
)

echo.
echo Windows Update Logs
echo.

echo Deleting directory: %WinDir%\Logs\WindowsUpdate
if exist "%WinDir%\Logs\WindowsUpdate" (
    rd /s /q "%WinDir%\Logs\WindowsUpdate" 2>nul
)

echo.
echo Windows Defender Logs Removal
echo.

echo Deleting log files: %ProgramData%\Microsoft\Windows Defender\Network Inspection System\Support\*.log
del /q "%ProgramData%\Microsoft\Windows Defender\Network Inspection System\Support\*.log" 2>nul

rem Delete directories
for %%d in (
    "%ProgramData%\Microsoft\Windows Defender\Scans\History\CacheManager"
    "%ProgramData%\Microsoft\Windows Defender\Scans\History\ReportLatency\Latency"
    "%ProgramData%\Microsoft\Windows Defender\Scans\MetaStore"
    "%ProgramData%\Microsoft\Windows Defender\Support"
    "%ProgramData%\Microsoft\Windows Defender\Scans\History\Results\Quick"
    "%ProgramData%\Microsoft\Windows Defender\Scans\History\Results\Resource"
) do (
    echo Deleting directory: %%d
    if exist "%%d" (
        rd /s /q "%%d" 2>nul
    )
)

rem .log files 
echo Deleting log files: %ProgramData%\Microsoft\Windows Defender\Scans\History\Service\*.log
del /q "%ProgramData%\Microsoft\Windows Defender\Scans\History\Service\*.log" 2>nul

echo.
echo Temp Files
echo.

rem Temp
echo Deleting all files and directories from C:\Windows\Temp
for /d %%d in ("C:\Windows\Temp\*") do rd /s /q "%%d"
del /q /f "C:\Windows\Temp\*.*" 2>nul

rem Temp LocalAppdata
echo Deleting all files and directories from %LocalAppData%\Temp
for /d %%d in ("%LocalAppData%\Temp\*") do rd /s /q "%%d"
del /q /f "%LocalAppData%\Temp\*.*" 2>nul

rem Prefetch
echo Deleting files from Prefetch
del /q /f "%SystemRoot%\Prefetch\*.*" 2>nul

rem SoftwareDistribution
echo Deleting files from C:\Windows\SoftwareDistribution\Download
del /q /f "C:\Windows\SoftwareDistribution\Download\*.*" 2>nul

echo.
echo Other Temp Directories
echo.

rem Other Temp Directories
for %%u in (%username%) do (
    echo Deleting directories for user %%u
    for %%d in (
        "C:\Users\%%u\AppData\Local\Microsoft\Internet Explorer\Cache"
        "C:\Users\%%u\AppData\Local\Microsoft\Internet Explorer\Recovery"
        "C:\Users\%%u\AppData\Local\Microsoft\Internet Explorer\Tiles"
        "C:\Users\%%u\AppData\Local\Microsoft\Terminal Server Client\Cache"
        "C:\Users\%%u\AppData\Local\Microsoft\Windows\IECompatCache"
        "C:\Users\%%u\AppData\Local\Microsoft\Windows\IECompatUaCache"
        "C:\Users\%%u\AppData\Local\Microsoft\Windows\IEDownloadHistory"
        "C:\Users\%%u\AppData\Local\Microsoft\Windows\INetCache"
        "C:\Users\%%u\AppData\Local\Microsoft\Windows\Temporary Internet Files"
        "C:\Users\%%u\AppData\Local\Microsoft\Windows\WebCache"
        "C:\Users\%%u\AppData\Local\Microsoft\Windows\WER"
        "%LOCALAPPDATA%\Microsoft\Edge"
    ) do (
        if exist "%%d" (
            rd /s /q "%%d" 2>nul
            echo Deleted directory: %%d
        )
    )
)

rem Microsoft Edge files remove
if exist "C:\Windows\System32\MicrosoftEdgeCP.exe" (
    echo Microsoft Edge detected, deleting additional directories...
    for /f "delims=" %%a in ('dir /b "C:\Windows\System32\MicrosoftEdge*"') do (
        echo Taking ownership of C:\Windows\System32\%%a
        takeown /f "C:\Windows\System32\%%a" > NUL 2>&1
        echo Setting permissions for C:\Windows\System32\%%a
        icacls "C:\Windows\System32\%%a" /inheritance:e /grant "%username%:(OI)(CI)F" /T /C > NUL 2>&1
        echo Deleting file C:\Windows\System32\%%a
        del /S /Q "C:\Windows\System32\%%a" > NUL 2>&1
    )
)

echo OneDriveSetup files remove
for %%p in (
    "%systemroot%\System32\OneDriveSetup.exe"
    "%systemroot%\SysWOW64\OneDriveSetup.exe"
) do (
    if exist "%%p" (
        echo Removing OneDriveSetup.exe: %%p...
        takeown /f "%%p" > NUL 2>&1
        icacls "%%p" /inheritance:e /grant "%UserName%:(OI)(CI)F" /T /C > NUL 2>&1
        del /f /q "%%p" > NUL 2>&1
        echo Removed OneDriveSetup.exe: %%p
    )
)

rem Clean Windows Event Logs
echo [+] Cleaning Windows Event Logs...
for /f "tokens=*" %%G in ('wevtutil el') do (
    echo [+] Clearing Event Log %%G...
    wevtutil cl "%%G" > NUL 2>&1
    echo Cleared Event Log %%G
)

echo Cleanup completed

echo.
echo Press any key to exit...
pause >nul
