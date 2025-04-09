#Requires -RunAsAdministrator
$folder = "."

# Read the Config.JSON file
$ConfigJson = Get-Content -Path "$($folder)\config.json" -Raw | ConvertFrom-Json

# Access the parameters
$name = $ConfigJson.Name
$WingetURL = $ConfigJson.WingetURL

$WingetSourceOutput = winget source list | Select-Object -skip 2
$parsedOutput = $WingetSourceOutput | ForEach-Object {
    $fields = $_ -split '\s+'
    [PSCustomObject]@{
        Name = $fields[0]
        Argument = $fields[1]
        Explicit = $fields[2]
    }
}
if (!($parsedOutput.name -contains $name))
    {
        "Winget Repository $($name) is not a Winget Source" 
    }else{
        winget source remove -n "$($Name)" 
    }


