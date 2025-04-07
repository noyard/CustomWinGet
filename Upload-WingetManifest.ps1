#Download manifest to folder c:\notepad\
#https://github.com/microsoft/winget-pkgs/tree/master/manifests/n/Notepad%2B%2B/Notepad%2B%2B/8.7.9

function Upload-WingetManifest {
    param (
        [Parameter(Mandatory=$true)]
        [string]$YamlFolder
    )


$folder = "."
# Read the Config.JSON file
$ConfigJson = Get-Content -Path "$($folder)\config.json" -Raw | ConvertFrom-Json
# Access the parameters
$Name = $ConfigJson.Name

#Open installer.yaml file in folder
# Read the YAML file
$yamlContent = Get-Content -Path $Yaml -Raw

# Convert YAML to PowerShell objects
$parsedData = ConvertFrom-Yaml -Yaml $yamlContent
$DestPath="manifests/$($($parsedData.Author).Substring(0,1))/$($parsedData.Author)/$($parsedData.PackageName)/$($parsedData.PackageVersion)"

#if files do not exist Download files

#Upload to new location

#update yaml with new url

# import into winget custom repository
Add-WinGetManifest -FunctionName "func-$($Name)" -Path $YamlFolder

# list all packages in custom repository
winget search --query . --source "$($Name)"