# Read the Config.JSON file
$ConfigJson = Get-Content -Path "$($folder)\config.json" -Raw | ConvertFrom-Json

# Access the parameters
$AzureCloud = $ConfigJson.AzureCloud
$Region = $ConfigJson.Region
$Subscription = $ConfigJson.Subscription
$ResourceGroup = $ConfigJson.ResourceGroup
$StorageAccountName =  $ConfigJson.StorageAccountName
$containerName =  $ConfigJson.containerName

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

az cloud set --name $AzureCloud
Connect-AzAccount -Environment $AzureCloud

if(!($(get-azcontext).Subscription.Id -eq $Subscription)) {
    Set-AzContext -SubscriptionId $Subscription
} 

# Create a Storage Account
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $resourcegroup -Name $StorageAccountName -ErrorAction Ignore
if (!($StorageAccount))
{  
    Write-Host "Creating Storage Account $($StorageAccountName)"
    New-AzStorageAccount -ResourceGroupName $resourcegroup  -Name $StorageAccountName -Location $region -SkuName "Standard_LRS" 
}

# Get the Storage Account Context
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourcegroup  -Name $StorageAccountName
$ctx = $storageAccount.Context

# Create a Container
$StorageAccount = Get-AzStorageContainer -Name $containerName -Context $ctx -ErrorAction Ignore
if (!($StorageAccount))
{  
    Write-Host "Creating Storage Container $($containerName)"
    New-AzStorageContainer -Name $containerName -Context $ctx
}
