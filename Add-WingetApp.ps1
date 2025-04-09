
# Add a manifest from a JSON file
Add-WinGetManifest -Path "C:\Packages\MyPackage.json" -RestSourceUrl "https://yourrestsource.com/api"
 
# Add manifests from a folder of YAML files
Add-WinGetManifest -Path "C:\Packages\MyPackages" -RestSourceUrl "https://yourrestsource.com/api"
 