param appPlanName string = '${uniqueString(resourceGroup().name)}'
param location string = resourceGroup().location

param planKind string = 'linux'

param skuName string = 'B1'
param skuTier string = 'Basic'
param skuSize string = 'B1'
param skuFamily string = 'B'
param skuCapacity int = 1

param workerSize int = 0
param workerSizeId int = 0
param numberOfWorkers string = '1'

param planSku object = {
  name: skuName
  tier: skuTier
  size: skuSize
  family: skuFamily
  capacity: skuCapacity
}

param properties object = {
  name: appPlanName
  workerSize: workerSize
  workerSizeId: workerSizeId
  numberOfWorkers: numberOfWorkers
  reserved: true
}

resource appPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appPlanName
  location: location
  kind: planKind
  sku: planSku
  properties: {
    name: appPlanName
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    reserved: true
  }
}

output planId string = appPlan.id
output planName string = appPlan.name
