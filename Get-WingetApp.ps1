function Get-WingetApp {
    param (
        [Parameter(Mandatory=$true)]
        [string]$packageId,

        [string]$scope = "machine",

        [string]$source = "winget"
    )

    # Check if Winget is installed
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "Winget is not installed on this system. Please install Winget first."
        return
    }

    # Check if Package Id is valid
    $result = winget search $packageId
        if ($result -match "No packages found") {
        Write-Output "Package ID '$packageId' does not exist."
        return
    } else {
        Write-Output "Package ID '$packageId' exists."
    }

    #Create temp folder to download to
    $parent = [System.IO.Path]::GetTempPath()
    $name = [System.IO.Path]::GetRandomFileName()
    $Location = Join-Path $parent $name
    New-Item -ItemType Directory -Path $Location

    # Construct the Winget download command
    $downloadCommand = "winget download --id $($packageId) --download-directory $($location) --Scope $($scope) --Source $($source)"

    # Download the app using Winget
    try {
        Invoke-Expression $downloadCommand
        Write-Output "The app with ID '$packageId' has been successfully downloaded to location '$Location'."
    }
    catch {
        Write-Error "An error occurred while trying to download the app with ID '$packageId' to location '$Location'."
    }

    $file = Get-ChildItem "$($location)\*.yaml"

    $yamlFile = Join-Path $location $file.name
    $yamlContent = Get-Content -Path $yamlFile -Raw
    $parsedData = ConvertFrom-Yaml -Yaml $yamlContent
    $packageIdentifier = $parseddata.PackageIdentifier
    $publisher = $packageidentifier.split('.')[0]
    $packageName = $packageidentifier.split('.')[1]
    $Version = $parsedData.PackageVersion  
    $PublisherFirst = $($Publisher.Substring(0, 1)).ToLower()
    $InstallerUrl = $parseddata.Installers.InstallerUrl
    $ManifestFolder = "./manifests/$($PublisherFirst)/$($publisher)/$($packageName)/$($Version)"

    if (!(Test-Path $ManifestFolder)) {New-Item -Path $ManifestFolder -ItemType "Directory"}

    #copy yaml to manifest folder
    Copy-Item -Path $file -Destination $ManifestFolder

    #copy install file to manifest folder
    $installFile = Get-ChildItem "$($location)\*$([System.IO.Path]::GetExtension($Installerurl))"
    $destinationFile = "$($ManifestFolder)/$($installerurl |Split-Path -Leaf)"
    
    #verify hash of install file
    Copy-Item -Path $installFile.FullName -Destination $destinationFile
    $calculatedHash = Get-FileHash -Path $destinationFile -Algorithm SHA256
    if ($calculatedHash.Hash -eq $parseddata.installers.InstallerSha256) {
        "The hash matches. The file integrity is verified."
     } else {
        "The hash does not match. The file may be corrupted."
     }
}

