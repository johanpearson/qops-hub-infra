// Container Registry Module
// Creates an Azure Container Registry for storing Docker images

@description('Location for the Container Registry')
param location string = resourceGroup().location

@description('Name of the Container Registry (must be globally unique, 5-50 alphanumeric)')
@minLength(5)
@maxLength(50)
param containerRegistryName string

@description('Resource tags')
param tags object = {}

@description('SKU name')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Enable admin user')
param adminUserEnabled bool = false

// Create Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: containerRegistryName
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    policies: {
      retentionPolicy: {
        status: 'disabled'
      }
    }
  }
}

// Outputs
output containerRegistryId string = containerRegistry.id
output containerRegistryName string = containerRegistry.name
output containerRegistryLoginServer string = containerRegistry.properties.loginServer
@secure()
output containerRegistryAdminUsername string = adminUserEnabled ? containerRegistry.listCredentials().username : ''
@secure()
output containerRegistryAdminPassword string = adminUserEnabled ? containerRegistry.listCredentials().passwords[0].value : ''
