[Info]
Title=Windows Defender
Description=Clean-up non critical files used by Windows Defender.
Author=Builtbybel
AuthorURL=http://www.builtbybel.com

[Files]
File1=DeleteFile|%ProgramData%\Microsoft\Windows Defender\Network Inspection System\Support\*.log
File2=DeleteDir|%ProgramData%\Microsoft\Windows Defender\Scans\History\CacheManager
File3=DeleteDir|%ProgramData%\Microsoft\Windows Defender\Scans\History\ReportLatency\Latency
File4=DeleteFile|%ProgramData%\Microsoft\Windows Defender\Scans\History\Service\*.log
File5=DeleteDir|%ProgramData%\Microsoft\Windows Defender\Scans\MetaStore
File6=DeleteDir|%ProgramData%\Microsoft\Windows Defender\Support
File7=DeleteDir|%ProgramData%\Microsoft\Windows Defender\Scans\History\Results\Quick
File8=DeleteDir|%ProgramData%\Microsoft\Windows Defender\Scans\History\Results\Resource







