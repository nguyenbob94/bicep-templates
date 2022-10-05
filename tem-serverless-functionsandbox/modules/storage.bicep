param storageName string
param location string

resource storageAccountBlob 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    isHnsEnabled: false
    minimumTlsVersion: 'TLS1_2'
  }
}

// Cannot pass key value through output. MS recommended way to achieve this is to output the storage resource ID and then call the storage account from the function module
output storageAccountID string = storageAccountBlob.id
output storageAccountApiVersion string = storageAccountBlob.apiVersion


