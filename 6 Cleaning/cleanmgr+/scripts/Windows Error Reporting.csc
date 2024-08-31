[Info]
Title=Windows Error Reporting
Description=Clean-up Windows Error Log files
Author=Builtbybel
AuthorURL=http://www.builtbybel.com

[Files]
File1=Detect|HKCU\Software\Microsoft\Windows\Windows Error Reporting
File2=DeleteFile|%LocalAppData%\PCHealth\ErrorRep\QSignoff\*.*
File3=DeleteDir|%WinDir%\pchealth\ERRORREP
File4=DeleteFile|%WinDir%\pchealth\helpctr\DataColl\*.xml
File5=DeleteDir|%WinDir%\pchealth\helpctr\OfflineCache
File6=DeleteFile|%WinDir%\System32\config\systemprofile\AppData\Local\CrashDumps\*.dmp
File7=DeleteFile|%WinDir%\System32\config\systemprofile\Local Settings\Application Data\CrashDumps\*.dmp
File8=DeleteFile|%WinDir%\SysWOW64\config\systemprofile\AppData\Local\CrashDumps\*.dmp
File9=DeleteFile|%WinDir%\SysWOW64\config\systemprofile\Local Settings\Application Data\CrashDumps\*.dmp
File10=DeleteDir|%AllUsersProfile%\Microsoft\Windows\WER\ReportQueue
File11=DeleteRegKey|HKCU\Software\Microsoft\Windows\Windows Error Reporting\Debug
File12=DeleteRegKey|HKLM\Software\Microsoft\Windows\Windows Error Reporting\FullLiveKernelReports\win32k.sys
File13=DeleteRegKey|HKLM\Software\Microsoft\Windows\Windows Error Reporting\LiveKernelReports\win32k.sys
File14=DeleteRegKey|HKLM\Software\Microsoft\Windows\Windows Error Reporting\LocalDumps



















