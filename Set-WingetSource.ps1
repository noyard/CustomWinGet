$folder = "."

# Read the Config.JSON file
$ConfigJson = Get-Content -Path "$($folder)\config.json" -Raw | ConvertFrom-Json

# Access the parameters
$Name = $ConfigJson.Name

winget source add -n "$($Name)" -t "Microsoft.Rest" -a "https://apim-$($Name).azure-api.net/winget/"