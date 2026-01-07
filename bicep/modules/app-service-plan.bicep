// App Service Plan Module
// Creates an Azure App Service Plan with configurable SKU

@description('Location for the App Service Plan')
param location string = resourceGroup().location

@description('Name of the App Service Plan')
param appServicePlanName string

@description('SKU configuration')
param sku object = {
  name: 'B1'
  tier: 'Basic'
  capacity: 1
}

@description('Resource tags')
param tags object = {}

@description('Kind of App Service Plan (Linux or Windows)')
@allowed([
  'Linux'
  'Windows'
])
param kind string = 'Linux'

// Create App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  kind: kind
  sku: {
    name: sku.name
    tier: sku.tier
    capacity: sku.capacity
  }
  properties: {
    reserved: kind == 'Linux'
  }
}

// Outputs
output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
