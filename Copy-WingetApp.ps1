function Copy-WingetMergedApp {
    param (
        [Parameter(Mandatory=$true)]
        [string]$yamlFolder
    )
    
    $folder = "."

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
            $Yaml = (Get-ChildItem "$($yamlfolder)/*installer.yaml").FullName

    }else{
            $Yaml = (Get-ChildItem "$($yamlfolder)/*.yaml").FullName
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
    
  # Upload the folder to the container
    Get-ChildItem -Path $yamlfolder -Recurse | ForEach-Object {
        $blobName = "$($ManifestFolder)\$($_.Name)"
        $filename = "$($_.FullName)"
        try{
            $blobInfo = Get-AzStorageBlob -Container $containerName -Blob $blobName -Context $ctx -ErrorAction Stop
            # If it exists, do not upload 
            Write-Output "$($blobName) already exists; skipping upload."
        }catch{ 
            Write-Host "Uploading $($blobName)..."
            Set-AzStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $ctx
        }
    }  
  
    #Modify Yaml with new locations of storage files
    $TempYaml = New-TemporaryFile
    Copy-Item -path $Yaml -Destination $TempYaml
    foreach ($installer in $parsedData.Installers)
        {
            $installerurlpath = $($installer.installerUrl) |Split-Path -Parent
            $installerurlpath  = $($installerurlpath.ToString()) -replace '\\', '/'
            $DestInstallerPath = "$($ctx.BlobEndPoint)$($ContainerName)$($ManifestFolder -replace '^\.', '')"
            $DestInstallerPath  = $($DestInstallerPath.ToString()) -replace '\\', '/'
            if (!($installerurlpath -like $DestInstallerPath))
                {
                (Get-Content $TempYaml).Replace("$installerurlpath", "$DestInstallerPath") | Set-Content $Yaml
                }
        }

    #upload modified Yaml file to the container
    $blobName = "$($ManifestFolder)/$($yaml | split-path -leaf)"
    Write-Host "Uploading $($blobName)..."
    Set-AzStorageBlobContent -File $Yaml -Container $containerName -Blob $blobName -Context $ctx -Force	
 
}
