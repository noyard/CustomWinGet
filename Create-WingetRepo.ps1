$folder = "."
$unziplocation = "$($folder)\WinGet.RestSource-Winget.PowerShell.Source"
if (!(Test-Path "$($unziplocation)\Microsoft.WinGet.RestSource.psd1"))
{
    $downloadlink = "https://github.com/microsoft/winget-cli-restsource/releases/latest/download/WinGet.RestSource-Winget.PowerShell.Source.zip"
    $downloadlocation = "$($folder)\WinGet.RestSource-Winget.PowerShell.Source.zip"
    $download = Invoke-WebRequest -Uri $downloadlink -OutFile $downloadlocation
    Expand-Archive -Path $downloadlocation -DestinationPath $unziplocation -Force
    Get-ChildItem -Path $unziplocation -Recurse | Unblock-File
}

Import-Module  "$($unziplocation)\Microsoft.WinGet.RestSource.psd1"

# Read the Config.JSON file
$ConfigJson = Get-Content -Path "$($folder)\config.json" -Raw | ConvertFrom-Json

# Access the parameters
$AzureCloud = $ConfigJson.AzureCloud
$Region = $ConfigJson.Region
$Subscription = $ConfigJson.Subscription
$ResourceGroup = $ConfigJson.ResourceGroup
$Name = $ConfigJson.Name
$implementationperformance = $ConfigJson.implementationperformance

# Check the current version of Azure CLI
$currentVersion = az --version | Select-String -Pattern "azure-cli" | ForEach-Object { $_.Line.Split() }

# Get the latest version of Azure CLI from the official repository
$latestVersion = (Invoke-RestMethod -Uri "https://api.github.com/repos/Azure/azure-cli/releases/latest").tag_name

# Compare the versions
if ($currentVersion -ne $latestVersion) {
    Write-Output "An upgrade is needed. Current version: $currentVersion, Latest version: $latestVersion"
} else {
    Write-Output "You are using the latest version of Azure CLI: $currentVersion"
}

if(!($(get-azcontext).environment.name -eq $AzureCloud)) {
    az cloud set --name $AzureCloud
    connect-AzAccount -Environment $AzureCloud
}

if(!($(get-azcontext).Subscription.Id -eq $Subscription)) {
    Set-AzContext -SubscriptionId $Subscription
} 

new-wingetsource -Name $Name -ResourceGroup $ResourceGroup -Region $Region -ImplementationPerformance $Implementationperformance -ShowConnectionInstructions -InformationAction Continue -Verbose
