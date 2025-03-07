# Config.json Settings

## AzureCloud
- One of the values from the command:
  ```sh
  az cloud list --query "[].name" -o tsv
  ```

## Region
- One of the values from the command:
  ```sh
  az account list-locations --query "[].name" -o tsv
  ```

## Subscription
- One of the values from the command:
  ```sh
  az account list --output table
  ```

## ResourceGroup
- One of the values from the command:
  ```sh
  az group list --output table
  ```

## Name
- Name of the Winget repo

## ImplementationPerformance
- Performance of the Winget repo (Basic, ,)
