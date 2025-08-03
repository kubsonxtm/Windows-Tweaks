$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    try {
        Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Definition)`"" -Verb RunAs
    }
    catch {
        Write-Error "Failed to elevate: $($_.Exception.Message)"
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        exit
    }
    exit
}

Function Remove-Bloatware {
    Write-Host "`nStarting bloatware removal process..." -ForegroundColor Yellow

    $Bloatware = @(
        "Clipchamp.Clipchamp"
        "Microsoft.3DBuilder"
        "Microsoft.549981C3F5F10"
        "Microsoft.BingFinance"
        "Microsoft.BingFoodAndDrink"
        "Microsoft.BingHealthAndFitness"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingTranslator"
        "Microsoft.BingTravel"
        "Microsoft.BingWeather"
        "Microsoft.Copilot"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftJournal"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftPowerBIForWindows"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.MicrosoftStickyNotes"
        "Microsoft.MixedReality.Portal"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.News"
        "Microsoft.Office.OneNote"
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.Print3D"
        "Microsoft.SkypeApp"
        "Microsoft.Todos"
        "Microsoft.WindowsAlarms"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.XboxApp"
        "Microsoft.ZuneVideo"
        "MicrosoftCorporationII.MicrosoftFamily"
        "MicrosoftCorporationII.QuickAssist"
        "MicrosoftTeams"
	    "Microsoft.WindowsCalculator"
        "Microsoft.ZuneMusic"
        "Microsoft.ScreenSketch"
        "Microsoft.Windows.Photos"
        "MSTeams"
        "ACGMediaPlayer"
        "ActiproSoftwareLLC"
        "AdobeSystemsIncorporated.AdobePhotoshopExpress"
        "Amazon.com.Amazon"
        "AmazonVideo.PrimeVideo"
        "Asphalt8Airborne"
        "AutodeskSketchBook"
        "CaesarsSlotsFreeCasino"
        "COOKINGFEVER"
        "CyberLinkMediaSuiteEssentials"
        "DisneyMagicKingdoms"
        "Disney"
        "DrawboardPDF"
        "Duolingo-LearnLanguagesforFree"
        "EclipseManager"
        "Facebook"
        "FarmVille2CountryEscape"
        "fitbit"
        "Flipboard"
        "HiddenCity"
        "HULULLC.HULUPLUS"
        "iHeartRadio"
        "Instagram"
        "king.com.BubbleWitch3Saga"
        "king.com.CandyCrushSaga"
        "king.com.CandyCrushSodaSaga"
        "LinkedInforWindows"
        "MarchofEmpires"
        "Netflix"
        "NYTCrossword"
        "OneCalendar"
        "PandoraMediaInc"
        "PhototasticCollage"
        "PicsArt-PhotoStudio"
        "Plex"
        "PolarrPhotoEditorAcademicEdition"
        "Royal Revolt"
        "Shazam"
        "Sidia.LiveWallpaper"
        "SlingTV"
        "Spotify"
        "TikTok"
        "TuneInRadio"
        "Twitter"
        "Viber"
        "WinZipUniversal"
        "Wunderlist"
        "XING"
        "Microsoft.BingSearch"
        "Microsoft.Copilot"
        "Microsoft.GamingApp"
        "Microsoft.GetHelp"
        "Microsoft.MSPaint"
        "Microsoft.OutlookForWindows"
        "Microsoft.People"
        "Microsoft.PowerAutomateDesktop"
        "Microsoft.RemoteDesktop"
        "Microsoft.StartExperiencesApp"
        "Microsoft.Whiteboard"
        "Microsoft.Windows.DevHome"
        "Microsoft.WindowsCamera"
        "Microsoft.windowscommunicationsapps"
        "Microsoft.WindowsTerminal"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.YourPhone"
        "MicrosoftWindows.CrossDevice"
        "Microsoft.HEIFImageExtension"
        "Microsoft.WebMediaExtensions"
        "Microsoft.WebpImageExtension"
        "Microsoft.Edge.GameAssist"
        "Microsoft.VP9VideoExtensions"
        "Microsoft.Wallet"
    )

    foreach ($app in $Bloatware) {
        $packages = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
        if ($packages) {
            foreach ($pkg in $packages) {
                Write-Host "Removing AppX: $($pkg.Name)"
                try {
                    Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop | Out-Null
                    Write-Host "SUCCESS: Removed $($pkg.Name)" -ForegroundColor Green
                }
                catch {
                    Write-Warning "Failed to remove $($pkg.Name): $($_.Exception.Message)"
                }
            }
        }
    }


    foreach ($app in $Bloatware) {
        $provisioned = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $app }
        if ($provisioned) {
            foreach ($pkg in $provisioned) {
                Write-Host "Removing provisioned: $($pkg.DisplayName)"
                try {
                    Remove-AppxProvisionedPackage -Online -PackageName $pkg.PackageName -ErrorAction Stop | Out-Null
                    Write-Host "SUCCESS: Removed provisioned package: $($pkg.DisplayName)" -ForegroundColor Green
                }
                catch {
                    Write-Warning "Failed to remove provisioned: $($pkg.DisplayName). Error: $($_.Exception.Message)"
                }
            }
        }
    }

    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    Start-Process explorer.exe

    Write-Host "`nDEBOLOAT COMPLETED!" -ForegroundColor Green
    Write-Host "Closing in 3 seconds..."
    Start-Sleep -Seconds 3
    exit
}

Remove-Bloatware

