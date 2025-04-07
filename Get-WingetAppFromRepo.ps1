function Download-WingetAppFromWinget-pkgs {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Publisher,

        [Parameter(Mandatory=$true)]
        [string]$PackageName,

        [string]$Version
    )

    $Publisher = "naaive"
    $PackageName = "Orange"
    #$Version = ""

    $PublisherFirst = $Publisher.Substring(0, 1)

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
    
    Foreach ($file in $jsondata)
        {
            "$($file.name)"
            "$($file.path)"
            "$($file.download_url)"
            "$($file.sha)"

            
        }
 
}

# Example usage:
# Download-WingetApp -AppId "Microsoft.VisualStudioCode" -Location "C:\Downloads\VSCode"