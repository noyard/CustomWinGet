function Get-WingetAppFromWinget-pkgs {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Publisher,

        [Parameter(Mandatory=$true)]
        [string]$PackageName,

        [string]$Version
    )
    $PublisherFirst = $($Publisher.Substring(0, 1)).ToLower()

    If (!($version))
    {  
        $DirUrl = "https://api.github.com/repositories/197275551/contents/manifests/$($PublisherFirst)/$( $Publisher)/$($PackageName)"
        $location = New-TemporaryFile
        Invoke-WebRequest -Uri $DirUrl -OutFile $location
        $jsonData = Get-Content -Raw -Path $location | ConvertFrom-Json
        $Version =$jsondata.name |Sort-Object -Descending | Select-Object -first 1
    }

    $DirUrl = "https://api.github.com/repositories/197275551/contents/manifests/$($PublisherFirst)/$( $Publisher)/$($PackageName)/$($Version)"
    $location = New-TemporaryFile
    Invoke-WebRequest -Uri $DirUrl -OutFile $location
    $jsonData = Get-Content -Raw -Path $location | ConvertFrom-Json
    
    #Download the files in the Github Winget Manifest folder
    Foreach ($file in $jsondata)
        {
            "    File : $($file.name)"
            "    Path : $($file.path)"
            "     url : $($file.download_url)"
            "     Sha : $($file.sha)"

            $ManifestFolder = ".\$($file.path | split-path)"
            if (!(Test-Path $ManifestFolder)) {New-Item -Path $ManifestFolder -ItemType "Directory"}
            Invoke-WebRequest -Uri $($file.download_url) -OutFile "./$($file.path)"
        }

    #Download the supporting files
    $Files = $jsonData | Where-Object { $_.Name -like "*Installer*" }
    Foreach ($file in $Files)
    {
        $yamlContent = Get-Content -Path "./$($file.path)" -Raw
        $parsedData = ConvertFrom-Yaml -Yaml $yamlContent
        $InstallerUrls = $parseddata.Installers.InstallerUrl
        Foreach ($Installer in $parseddata.Installers)
            {
                $DestinationFile = "$($ManifestFolder)\$($Installer.InstallerUrl | Split-Path -Leaf)"
                "Downloading $DestinationFile"
                If (!(Test-Path $DestinationFile)) {Invoke-WebRequest -Uri $Installer.InstallerUrl -OutFile $DestinationFile}
                $calculatedHash = Get-FileHash -Path $DestinationFile -Algorithm SHA256
                if ($calculatedHash.Hash -eq $Installer.InstallerSha256) {
                    "The hash matches. The file integrity is verified."
                 } else {
                    "The hash does not match. The file may be corrupted."
                 }
            }
    }    
}