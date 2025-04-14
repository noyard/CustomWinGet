# CustomWinGet
This solution will allow you to create a Custom WinGet repository, load it with content from public Winget repositories, and redirect the install files to a storage account.

Create-WingetRepo.ps1
    Creates a Winget Custom Repository using 

Create-WingetStorage.ps1
    Creates a storage account to store package modified JSON files and executables. 

Copy-WingetApp.ps1 
    Modifies the JSON files to point the install files to the storage account and copies install files to the storage account in the same format as Winget-pkgs manifests on Github

Get-WingetApp.ps1
    Uses the Winget download command to download a manifest and install file.  This manifest is "merged".

Get-WingetAppFromWinget-pkgs.ps1
    Download a copy of the public application manifest repository https://github.com/microsoft/winget-pkgs/tree/master/manifests.

Add-WingetApp.ps1
    Add the specified manifest to the Custom winget rest source.

Set-WingetSource.ps1
    Sets the Custom winget rest source as a Winget Source on the machine executed on. 

Remove-WingetSource.ps1
    Removes the Custom winget rest source as a Winget Source on the machine executed on. 



----- Additional notes -----

To get a list of available WinGet packages
winget search --name "" --source "{restsource name}" >.\applist.csv

Verify the syntax by executing the following command:
winget validate --manifest <path-to-manifest>

Test the install by executing the following command:
winget install --manifest <path-to-manifest>
