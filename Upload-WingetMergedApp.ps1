function Upload-WingetMergedApp {
    param (
        [Parameter(Mandatory=$true)]
        [string]$yamlFolder
    )
    
    # Read the Config.JSON file
    $ConfigJson = Get-Content -Path "$($folder)\config.json" -Raw | ConvertFrom-Json

    # Access the parameters
    $ResourceGroup = $ConfigJson.ResourceGroup
    $StorageAccountName =  $ConfigJson.StorageAccountName
    $containerName =  $ConfigJson.containerName

    $storageAccount = Get-AzStorageAccount -ResourceGroupName $resourcegroup  -Name $StorageAccountName
    $ctx = $storageAccount.Context

    # Read the YAML file
    if(test-path "$($yamlfolder)/*installer.yaml")
        {
            $Yaml = (Get-ChildItem "$($location)/*installer.yaml").FullName

    }else{
            $Yaml = (Get-ChildItem "$($location)/*.yaml").FullName
    }      

    $yamlContent = Get-Content -Path $Yaml -Raw

    # Convert YAML to PowerShell objects
    $parsedData = ConvertFrom-Yaml -Yaml $yamlContent
    $packageIdentifier = $parseddata.PackageIdentifier
    $publisher = $packageidentifier.split('.')[0]
    $packageName = $packageidentifier.split('.')[1]
    $Version = $parsedData.PackageVersion  
    $PublisherFirst = $($Publisher.Substring(0, 1)).ToLower()
    $ManifestFolder = "./manifests/$($PublisherFirst)/$($publisher)/$($packageName)/$($Version)"
    $DestPath="manifests/$($($parsedData.Author).Substring(0,1))/$($parsedData.Author)/$($parsedData.PackageName)/$($parsedData.PackageVersion)"

    # Upload the folder to the container
    Get-ChildItem -Path $location -Recurse | ForEach-Object {
        $filePath = $_.FullName
        $blobName = $_.FullName.Substring($folderPath.Length + 1).Replace("\", "/")
        Write-Host "Uploading $blobName..."
        Set-AzStorageBlobContent -File $filePath -Container $containerName -Blob $blobName -Context $ctx
    }
  
    #Modify Yaml with new locations of storage files
    $TempYaml = New-TemporaryFile
    $DestInstallerPath="$($ctx.BlobEndPoint)$($ContainerName)/$($DestPath)/$($InstallerFilename)"
        (Get-Content $Yaml).Replace($InstallerUrl, $DestInstallerPath) | Set-Content $TempYaml

        #upload Yaml file to the container
        $blobName = "$($DestPath)\$($YamlFilename)"
        Set-AzStorageBlobContent -File $TempYaml -Container $containerName -Blob $blobName -Context $ctx 	
 
}
