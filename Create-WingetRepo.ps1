Create Winget Repo
$folder = "."
#$downloadlink = "https://github.com/microsoft/winget-cli-restsource/releases/latest/download/WinGet.RestSource-Winget.PowerShell.Source.zip"
$downloadlocation = "$folder\WinGet.RestSource-Winget.PowerShell.Source.zip"
#$download = Invoke-WebRequest -Uri $downloadlink -OutFile $downloadlocation

$unziplocation = "$folder\WinGet.RestSource-Winget.PowerShell.Source"
#Expand-Archive -Path $downloadlocation -DestinationPath $unziplocation -Force
#Get-ChildItem -Path $unziplocation -Recurse | Unblock-File
Import-Module  "$($unziplocation)\Microsoft.WinGet.RestSource.psd1"

