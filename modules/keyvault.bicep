param vaultPrefix string = 'kv'

param resourceTags object = {
  environment: 'Development'
  application: 'keyVaultModule'
}

param location string = resourceGroup().location

// keyvault default permission parameters
param objectid string = '8aa7fa6a-253a-4900-b77a-065652d2d9b9' 
param accessPolicies array = [
  {
    tenantId: subscription().tenantId
    objectId: objectid
    permissions: {
      keys:[
        'all'
        'list'
        'get'
      ]
      secrets:[
        'all'
        'list'
        'get'
      ]
    }
  }
]



param keyVaultName string = '${vaultPrefix}${uniqueString(resourceGroup().name)}'
param skuFamily string = 'A'
param skuName string = 'Standard'

resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  tags: resourceTags
  location: location
  properties: {
    sku: {
      family: skuFamily
      name: skuName
    }
    tenantId: subscription().tenantId
    accessPolicies: accessPolicies
  }
}

output keyVaultId string = vault.id
output keyVaultName string = vault.name
