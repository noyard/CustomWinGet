function Download-WingetApp {
    param (
        [Parameter(Mandatory=$true)]
        [string]$AppId,

        [Parameter(Mandatory=$true)]
        [string]$Location
    )

    # Check if Winget is installed
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "Winget is not installed on this system. Please install Winget first."
        return
    }

    # Construct the Winget download command
    $downloadCommand = "winget download --id $AppId --download-directory $Location --Scope machine"

    # Download the app using Winget
    try {
        Invoke-Expression $downloadCommand
        Write-Output "The app with ID '$AppId' has been successfully downloaded to location '$Location'."
    }
    catch {
        Write-Error "An error occurred while trying to download the app with ID '$AppId' to location '$Location'."
    }
}

# Example usage:
# Download-WingetApp -AppId "Microsoft.VisualStudioCode" -Location "C:\Downloads\VSCode"