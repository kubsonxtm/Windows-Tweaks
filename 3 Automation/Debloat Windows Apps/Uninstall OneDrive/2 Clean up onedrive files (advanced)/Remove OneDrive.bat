@echo off
setlocal enabledelayedexpansion

echo Checking for ExecTI process...
tasklist /FI "IMAGENAME eq ExecTI.exe" | find /I "ExecTI.exe" >nul 2>&1

if '%errorlevel%' == '0' (
    echo ExecTI detected. Running full cleanup...
    goto :fullCleanup
) else (
    echo ExecTI not detected. Removing OneDrive folder in Admin mode...
    goto :runAsAdmin
)

:runAsAdmin
:: Ensure script runs in Administrator mode for the OneDrive removal operation
echo Removing the OneDrive folder from a Microsoft location
rd /s /q "%localappdata%\Microsoft\OneDrive"
pause
exit /b

:fullCleanup
echo Proceeding with full OneDrive cleanup...

echo Cleaning OneDrive folders
rd /s /q "%localappdata%\Microsoft\OneDrive"
rd /s /q "%programdata%\Microsoft OneDrive"
rd /s /q "%systemdrive%\OneDriveTemp"
for /f "delims=" %%i in ('dir /b /a-d "%userprofile%\OneDrive"') do set "DIR_NOT_EMPTY=1"
if not defined DIR_NOT_EMPTY (
    rd /s /q "%userprofile%\OneDrive"
)

echo Disabling OneDrive using group policy
reg add "HKLM\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f

echo Removing OneDrive from the File Explorer
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f
reg add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f

echo Removing OneDrive from startup
reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
reg unload "hku\Default"

echo Removing OneDrive start menu shortcut
del /f /q "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

echo Deleting scheduled tasks
for /f "delims=" %%i in ('schtasks /query /fo list /v ^| findstr /i "OneDrive"') do (
    schtasks /delete /tn "%%i" /f
)

echo Removing OneDrive files from SysWOW64/System32
del /f /q "C:\Windows\SysWOW64\OneDriveSetup.exe"
del /f /q "C:\Windows\SysWOW64\OneDrive.ico"
del /f /q "C:\Windows\SysWOW64\OneDriveSettingSyncProvider.dll"
del /f /q "C:\Windows\System32\OneDriveSettingSyncProvider.dll"

taskkill /f /im ExecTI.exe >nul 2>&1

echo Run bat again but as admin (without ExecTI)

pause
exit /b
