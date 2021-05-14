
param synapsePrefix string = 'syn'
param location string = resourceGroup().location
param resourceTags object = {
  environment: 'Development'
  application: 'Analytics'
}


param sqlLogin string
param sqlPw string = 'Z${uniqueString('blabla')}!'

var synapseName = '${synapsePrefix}${uniqueString(resourceGroup().name)}'
var keyVaultName = 'kv${uniqueString(resourceGroup().name)}'

module synst 'modules/storage.bicep' = {
  name: 'synStorage'
  params: {
    isHnsEnabled:true
    location: location
    resourceTags: resourceTags
    storagePrefix: 'synst'
    storageSKU: 'Standard_LRS'
  }
}

module vault 'modules/keyvault.bicep' = {
  name: 'keyVault'
  params: {
    keyVaultName: keyVaultName
    location: location
  }
}

var secretName = '${keyVaultName}/sqlPassword'

resource sqlPassword 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: secretName
  dependsOn: [
    vault
  ]
  properties: {
    attributes: {
      enabled: true
    }
    value: sqlPw
  }
}

resource synapse 'Microsoft.Synapse/workspaces@2021-03-01' = {
  name: synapseName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: 'https://${synst.outputs.accountName}.dfs.core.windows.net/'
      filesystem: '${synst.outputs.containerName}'
    }
    publicNetworkAccess: 'Enabled'
    managedVirtualNetwork: 'default'
    sqlAdministratorLogin: sqlLogin
    sqlAdministratorLoginPassword: sqlPw
  }
}

output sqlAdministratorLogin string = sqlLogin
output sqlAdministratorLoginPassword string = sqlPw
