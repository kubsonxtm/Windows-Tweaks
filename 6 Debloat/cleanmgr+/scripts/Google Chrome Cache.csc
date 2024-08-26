[Info]
Title=Google Chrome
Description=Clean-up Google Chrome Cache
Author=Builtbybel
AuthorURL=http://www.builtbybel.com

[Files]
Task=TaskKill|chrome.exe|WARNING
File1=DeleteDir|%LocalAppData%\Google\Chrome\User Data\Default\Cache
File2=DeleteDir|%LocalAppData%\Google\Chrome\User Data\Default\Media Cache
File3=DeleteDir|%LocalAppData%\Google\Chrome\User Data\Default\GPUCache
File4=DeleteDir|%LocalAppData%\Google\Chrome\User Data\Default\Storage\ext
File5=DeleteDir|%LocalAppData%\Google\Chrome\User Data\Default\Service Worker
File6=DeleteDir|%LocalAppData%\Google\Chrome\User Data\ShaderCache








