function Add-Wingetpp {
    param (
        [Parameter(Mandatory=$true)]
        [string]$yamlFolder
    )
$folder = "."

# Read the Config.JSON file
$ConfigJson = Get-Content -Path "$($folder)\config.json" -Raw | ConvertFrom-Json

# Access the parameters
$Name = $ConfigJson.Name
$FunctionName = "func-$($Name)"
 
#If yaml is a file make sure it is merged
#if yaml is a folder continue

# Add manifests from a folder of YAML files
Add-WinGetManifest -FunctionName $FunctionName -Path $yamlFolder 
}