param vaultPrefix string = 'kv'
param location string = resourceGroup().location
param objectid string = '8aa7fa6a-253a-4900-b77a-065652d2d9b9'

param keyVaultName string = '${vaultPrefix}${uniqueString(resourceGroup().name)}'

resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family:'A'
      name:'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies:[
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
  }
}

output keyVaultId string = vault.id
output keyVaultName string = vault.name
