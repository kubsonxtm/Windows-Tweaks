[Info]
Title=Microsoft Edge Cache (Chromium Edge)
Description=Clean-up Cache of Microsoft Edge
Author=Builtbybel
AuthorURL=http://www.builtbybel.com

[Files]
Task=TaskKill|msedge.exe|WARNING
File1=DeleteDir|%LocalAppData%\Microsoft\Edge\User Data\Default\Cache
File2=DeleteDir|%LocalAppData%\Microsoft\Edge\User Data\Default\Media Cache
File3=DeleteDir|%LocalAppData%\Microsoft\Edge\User Data\Default\GPUCache
File4=DeleteDir|%LocalAppData%\Microsoft\Edge\User Data\Default\Storage\ext
File5=DeleteDir|%LocalAppData%\Microsoft\Edge\User Data\Default\Service Worker
File6=DeleteDir|%LocalAppData%\Microsoft\Edge\User Data\ShaderCache
File7=DeleteDir|%LocalAppData%\Microsoft\Edge SxS\User Data\Default\Cache
File8=DeleteDir|%LocalAppData%\Microsoft\Edge SxS\User Data\Default\Media Cache
File9=DeleteDir|%LocalAppData%\Microsoft\Edge SxS\User Data\Default\GPUCache
File10=DeleteDir|%LocalAppData%\Microsoft\Edge SxS\User Data\Default\Storage\ext
File11=DeleteDir|%LocalAppData%\Microsoft\Edge SxS\User Data\Default\Service Worker
File12=DeleteDir|%LocalAppData%\Microsoft\Edge SxS\User Data\ShaderCache
