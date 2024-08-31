[Info]
Title=Mozilla Firefox Cache
BrowserID=Mozilla\Firefox
Description=Clean-up Mozilla Firefox Cache
Author=Builtbybel
AuthorURL=http://www.builtbybel.com

[Files]
Task=TaskKill|Firefox.exe|WARNING
File1=DeleteDir|$MozillaProfileCache$\cache2\entries
File2=DeleteDir|$MozillaProfileCache$\jumpListCache
File3=DeleteDir|$MozillaProfileCache$\thumbnails
File4=DeleteDir|$MozillaProfileCache$\startupCache













