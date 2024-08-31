[Info]
Title=Windows Event Logs
Description=The Windows Event Viewer Logs show a detailed log of application and system messages, including errors, information messages, and warnings. Advanced users might find the details in event viewer logs helpful when troubleshooting problems with Windows and other apps. However, you may also wish to be able to quickly cleanup all event viewer logs at once as needed with this option using Windows command prompt.
Author=Builtbybel
AuthorURL=http://www.builtbybel.com

[Files]
File1=Detect|HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog
File2=Calc|%SystemRoot%\SysNative\Winevt\Logs
File3=Calc|%SystemRoot%\System32\Winevt\Logs
Task1=Exec|for /F "tokens=*" %1 in ('wevtutil.exe el') DO wevtutil.exe cl "%1"|SHOWCLI
















