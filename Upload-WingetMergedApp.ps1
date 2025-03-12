function Upload-WingetMergedApp {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Yaml
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
    $yamlContent = Get-Content -Path $Yaml -Raw

    # Convert YAML to PowerShell objects
    $parsedData = ConvertFrom-Yaml -Yaml $yamlContent
    $DestPath="manifests/$($($parsedData.Author).Substring(0,1))/$($parsedData.Author)/$($parsedData.PackageName)/$($parsedData.PackageVersion)"

    If ($parsedData.ManifestType -eq "merged")
    {
        #Download needed install files
        $InstallerUrl = $parseddata.Installers.InstallerUrl
        $InstallerFilename = Split-Path $InstallerUrl -leaf
        $TempFile = New-TemporaryFile
        Invoke-WebRequest -Uri $InstallerUrl -OutFile $TempFile
        
        # Upload the file to the container
        $blobName = "$($DestPath)\$($InstallerFilename)"
        Set-AzStorageBlobContent -File $TempFile -Container $containerName -Blob $blobName -Context $ctx

        #Modify Yaml with new locations of storage files
        $TempYaml = New-TemporaryFile
        $DestInstallerPath="$($ctx.BlobEndPoint)$($ContainerName)/$($DestPath)/$($InstallerFilename)"
        (Get-Content $Yaml).Replace($InstallerUrl, $DestInstallerPath) | Set-Content $TempYaml

        #upload Yaml file to the container
        $blobName = "$($DestPath)\$($YamlFilename)"
        Set-AzStorageBlobContent -File $TempYaml -Container $containerName -Blob $blobName -Context $ctx 	
    }else{
        Write-Host 'Yaml file is not merged, use the command "Winget download {winget id} --download-directory {folder} --Scope machine"'
    }
}
