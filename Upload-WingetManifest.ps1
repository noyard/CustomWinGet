#Download manifest to folder c:\notepad\
#https://github.com/microsoft/winget-pkgs/tree/master/manifests/n/Notepad%2B%2B/Notepad%2B%2B/8.7.9

$folder = "."

# Read the Config.JSON file
$ConfigJson = Get-Content -Path "$($folder)\config.json" -Raw | ConvertFrom-Json

# Access the parameters
$Name = $ConfigJson.Name

# import into winget custom repository
Add-WinGetManifest -FunctionName "func-$($Name)" -Path "C:\notepad\"

# list all packages in custom repository
winget search --query . --source "$($Name)"