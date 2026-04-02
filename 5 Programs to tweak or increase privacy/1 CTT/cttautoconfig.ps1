$url = "https://raw.githubusercontent.com/kubsonxtm/Windows-Tweaks/main/5%20Programs%20to%20tweak%20or%20increase%20privacy/1%20CTT/cttsettings.json"
$configFile = "$env:TEMP\cttsettings.json"
Invoke-WebRequest -Uri $url -OutFile $configFile -UseBasicParsing

& ([ScriptBlock]::Create((irm "https://christitus.com/win"))) -Config $configFile