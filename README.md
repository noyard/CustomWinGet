# CustomWinGet
Custom WinGet repository that you select which content you would like to provide

To get a list of available WinGet packages
winget list --source "winget" >.\applist.csv

Verify the syntax by executing the following command:
winget validate --manifest <path-to-manifest>

Test the install by executing the following command:
winget install --manifest <path-to-manifest>
