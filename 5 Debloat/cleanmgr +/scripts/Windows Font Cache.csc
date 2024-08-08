[Info]
Title=Windows Font Cache
Description=Windows creates a cache for the fonts so that they can load faster everytime you start a program, app, Explorer, etc. Recommendation: If you are facing Font problems, where the fonts are not rendering properly or displaying invalid characters on your computer, maybe the Font Cache has become corrupt. To resolve the issue, you can cleanup and rebuild the Font Cache with this option.
Author=Builtbybel
AuthorURL=http://www.builtbybel.com

[Files]
Task1=Exec|net stop FontCache
Task2=Exec|net stop FontCache3.0.0.0
File1=DeleteFile|%WinDir%\ServiceProfiles\LocalService\AppData\Local\FontCache\*.dat
File2=DeleteFile|%WinDir%\SysNative\FNTCACHE.DAT
File3=DeleteFile|%WinDir%\System32\FNTCACHE.DAT
Task3=Exec|net start FontCache
Task4=Exec|net start FontCache3.0.0.0













