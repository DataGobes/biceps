@minLength(3)
@maxLength(11)
param storagePrefix string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string = 'Standard_LRS'
param isHnsEnabled bool = false

param location string
param resourceTags object

var uniqueStorageName = '${storagePrefix}${uniqueString(resourceGroup().name)}'

resource stg 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: uniqueStorageName
  location: location
  tags: resourceTags
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    isHnsEnabled: isHnsEnabled
    minimumTlsVersion: 'TLS1_2'
  }
}


resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: '${stg.name}/default/data'
}

output storageEndpoint object = stg.properties.primaryEndpoints
output accountName string = stg.name
output containerName string = container.name
