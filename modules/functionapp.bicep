param subscriptionId string = subscription().id
param functionAppName string = 'functionApp${uniqueString(resourceGroup().name)}'
param location string = resourceGroup().location
param hostingPlanName string = 'plan${uniqueString(resourceGroup().name)}'
param serverFarmResourceGroup string = resourceGroup().name
param alwaysOn bool = true
param storageAccountName string = 'funcstore${uniqueString(resourceGroup().name)}'
param use32BitWorkerProcess bool = false
param linuxFxVersion string = 'Python|3.9'
param planSku string = 'Dynamic'
param planSkuCode string = 'Y1'
param workerSize string = '0'
param workerSizeId string = '0'
param numberOfWorkers string = '1'

var insightsName = 'insights${uniqueString(resourceGroup().name)}'

resource functionApp 'Microsoft.Web/sites@2018-11-01' = {
  name: functionAppName
  location: location
  tags: {}
  kind: 'functionapp,linux'
  properties: {
    name: functionAppName
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference('microsoft.insights/components/${insightsName}', '2015-05-01').InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: reference('microsoft.insights/components/${insightsName}', '2015-05-01').ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
      ]
      use32BitWorkerProcess: use32BitWorkerProcess
      linuxFxVersion: linuxFxVersion
    }
    serverFarmId: '/subscriptions/${subscriptionId}/resourcegroups/${serverFarmResourceGroup}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
    clientAffinityEnabled: false
  }
  dependsOn: [
    appPlan
  ]
}

module appPlan 'serviceplan.bicep' = {
  name: 'deploy_ServicePlan'
  params: {
    appPlanName: hostingPlanName
    location: location
    planSku: {
      tier: planSku
      name: planSkuCode
    }
    properties: {
      reserved: true
    }
    
  }
}

resource insights 'microsoft.insights/components@2020-02-02-preview' = {
  name: insightsName
  kind: 'web'
  location: location
  tags: {}
  properties: {
    ApplicationId: functionAppName
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    Application_Type: 'web'
    WorkspaceResourceId: '/subscriptions/7a906504-969b-4bbd-a4ec-7fe42c2b769a/resourcegroups/defaultresourcegroup-weu/providers/microsoft.operationalinsights/workspaces/defaultworkspace-7a906504-969b-4bbd-a4ec-7fe42c2b769a-weu'
  }
  dependsOn: []
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  tags: {}
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    allowBlobPublicAccess: false
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}
