[Info]
Title=Opera Cache
Description=Clean-up Opera Cache
Author=Builtbybel
AuthorURL=http://www.builtbybel.com

[Files]
Task=TaskKill|opera.exe|WARNING
File1=DeleteDir|%LocalAppData%\Opera Software\Opera Stable\cache
File2=DeleteDir|%AppData%\Opera Software\Opera Stable\GPUCache
File3=DeleteDir|%AppData%\Opera Software\Opera Stable\ShaderCache
File4=DeleteDir|%AppData%\Opera Software\Opera Stable\Jump List Icons
File5=DeleteDir|%AppData%\Opera Software\Opera Stable\Jump List IconsOld\Jump List Icons













