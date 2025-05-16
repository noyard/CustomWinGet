# Read the Config.JSON file
$folder = "."
$ConfigJson = Get-Content -Path "$($folder)\config.json" -Raw | ConvertFrom-Json

# Parameters
$storageAccountName = $ConfigJson.StorageAccountName
$resourceGroupName = $ConfigJson.ResourceGroup
$containerName = $ConfigJson.containerName
$AzureCloud = $ConfigJson.AzureCloud
$Region = $ConfigJson.Region
$Subscription = $ConfigJson.Subscription

az cloud set --name $AzureCloud
Connect-AzAccount -Environment $AzureCloud

if(!($(get-azcontext).Subscription.Id -eq $Subscription)) {
    Set-AzContext -SubscriptionId $Subscription
} 

# Get storage account context
$storageContext = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Context

# List all blobs with .yaml or .yml extension
$blobs = Get-AzStorageBlob -Container $containerName -Context $storageContext | 
    Where-Object { $_.Name -like "*.yaml" -or $_.Name -like "*.yml" }

# Display results
if ($blobs) {
    Write-Host "YAML files found in container '$containerName':"
    $blobs | ForEach-Object {
        Write-Host "- $($_.Name) (Size: $($_.Length) bytes, Last Modified: $($_.LastModified))"
    }
} else {
    Write-Host "No YAML files found in container '$containerName'."
}