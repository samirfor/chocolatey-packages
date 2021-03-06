import-module au;

function global:au_SearchReplace {
    @{
        '.\legal\VERIFICATION.txt' = @{
            "(?i)(\s+x32:).*"                           = "`${1} $($Latest.URL32)"
            "(?i)(checksum32:).*"                       = "`${1} $($Latest.Checksum32)"
            "(?i)(Get-RemoteChecksum).*"                = "`${1} $($Latest.URL32)"
            "(?i)(File 'LICENSE.txt' obtained from:).*" = "`${1} $($Latest.License)"
        }
     };
}

function global:au_BeforeUpdate {
    Get-RemoteFiles -Purge;
}

function global:au_GetLatest {
    $versionUri = 'https://netbeans.org/downloads/start.html?platform=windows&lang=en&option=javase'
    $versionPage = Invoke-WebRequest -Uri $versionUri -UserAgent "Update checker of Chocolatey Community Package 'Netbeans'" -UseBasicParsing

    [regex]$regex   = 'PAGE_ARTIFACTS_LOCATION\s*=\s*".*?/([\d.]+)/'
    $versionPage.Content -match $regex | Out-Null
    $latestVersion = $matches[1]

    $releasesUrl = "http://download.netbeans.org/netbeans/$latestVersion/final/bundles/netbeans-$latestVersion-javase-windows.exe"

    $latestVerionWithoutPoint = $latestVersion -replace '\.',''

    $outputLicenseFile  = ".\legal\LICENSE.txt"
    $licenceUrl         = "https://netbeans.org/downloads/licence/$latestVersion/nb$latestVerionWithoutPoint-LICENSE.txt"
    Invoke-WebRequest -Uri $licenceUrl -UseBasicParsing -OutFile $outputLicenseFile

    $Latest = @{
        Version = $latestVersion
        URL32   = $releasesUrl
        License = $licenceUrl
    }

    return $Latest
}

Update-Package -ChecksumFor none
