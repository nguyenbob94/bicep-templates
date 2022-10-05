targetScope = 'subscription'

//Global parameters
param rgName string
param location string
param storageName string

//Azure Function App name variables

var functionName = take(uniqueString(rG.id),5)
var appServicePlanName = 'asp-${functionName}'

// Deploying an Azure Function depends on the following resources
// Storage Account
// App Hosting Plan (serverfarms). Y1 for consumption
//
// Function Worker Name

resource rG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module storageModule './modules/storage.bicep' = {
  name: storageName
  scope: rG
  params: {
    location: location
    storageName: storageName
  }
}

module functionAppModule './modules/functionapp.bicep' = {
  name: appServicePlanName
  scope: rG
  params: {
    functionName: functionName
    appServicePlanName: appServicePlanName
    location: location
    storageName: storageName
    storageID: storageModule.outputs.storageAccountID
    storageApiVersion: storageModule.outputs.storageAccountApiVersion
  }
}
