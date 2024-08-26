[Info]
Title=Windows Icon Cache
Description=This will completely clean-up and rebuild the Icon Cache Database and refresh the Icon Cache, using Windows command-line.
Author=Builtbybel
AuthorURL=http://www.builtbybel.com
Warning=You may need to restart explorer.exe for this to take effect.

[Files]
Task1=Exec|%WinDir%\SysNative\ie4uinit.exe -show
Task2=Exec|%WinDir%\System32\ie4uinit.exe -show
File1=DeleteFile|%LocalAppData%\IconCache.db
File2=DeleteFile|%LocalAppData%\Microsoft\Windows\Explorer\iconcache_*.db