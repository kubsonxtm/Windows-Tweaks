[Info]
Title=Waterfox Cache
BrowserID=Waterfox
Description=Clean-up Waterfox Cache
Author=Builtbybel
AuthorURL=http://www.builtbybel.com

[Files]
Task=TaskKill|Waterfox.exe|WARNING
File1=DeleteDir|$MozillaProfileCache$\cache2\entries
File2=DeleteDir|$MozillaProfileCache$\jumpListCache
File3=DeleteDir|$MozillaProfileCache$\thumbnails















