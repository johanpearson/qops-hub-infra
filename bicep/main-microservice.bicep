// Example: Microservice Deployment
// This example deploys infrastructure for a containerized microservice:
// - Container Registry
// - App Service Plan (Linux)
// - App Service with container support
// - Application Insights
// - Log Analytics Workspace
// - Key Vault

targetScope = 'resourceGroup'

// Parameters
@description('Environment name (dev, test, staging, prod)')
param environment string

@description('Workload name (short identifier for the application)')
param workloadName string

@description('Azure region')
param location string = resourceGroup().location

@description('Azure region short code')
param regionCode string = 'weu'

@description('Application name')
param applicationName string

@description('Cost center')
param costCenter string = ''

@description('Owner')
param owner string = ''

@description('Docker image name')
param dockerImage string = 'nginx:latest'

// Import shared modules
module naming 'shared/naming.bicep' = {
  name: 'naming'
  params: {
    environment: environment
    workloadName: workloadName
    regionCode: regionCode
  }
}

module tagging 'shared/tags.bicep' = {
  name: 'tagging'
  params: {
    environment: environment
    applicationName: applicationName
    costCenter: costCenter
    owner: owner
  }
}

// Deploy Log Analytics Workspace
module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'logAnalytics'
  params: {
    location: location
    logAnalyticsName: naming.outputs.logAnalytics
    tags: tagging.outputs.tags
    retentionInDays: 30
  }
}

// Deploy Application Insights
module appInsights 'modules/app-insights.bicep' = {
  name: 'appInsights'
  params: {
    location: location
    appInsightsName: naming.outputs.appInsights
    tags: tagging.outputs.tags
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

// Deploy Container Registry
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    location: location
    containerRegistryName: naming.outputs.containerRegistry
    tags: tagging.outputs.tags
    sku: 'Basic'
    adminUserEnabled: true
  }
}

// Deploy Key Vault
module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    keyVaultName: naming.outputs.keyVault
    tags: tagging.outputs.tags
    enableRbacAuthorization: true
  }
}

// Deploy App Service Plan
module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: location
    appServicePlanName: naming.outputs.appServicePlan
    tags: tagging.outputs.tags
    sku: {
      name: 'B1'
      tier: 'Basic'
      capacity: 1
    }
    kind: 'Linux'
  }
}

// Deploy App Service for Container
module appService 'modules/app-service.bicep' = {
  name: 'appService'
  params: {
    location: location
    appServiceName: naming.outputs.appService
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    tags: tagging.outputs.tags
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
    appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
    linuxFxVersion: 'DOCKER|${dockerImage}'
    appSettings: [
      {
        name: 'DOCKER_REGISTRY_SERVER_URL'
        value: 'https://${containerRegistry.outputs.containerRegistryLoginServer}'
      }
      {
        name: 'DOCKER_REGISTRY_SERVER_USERNAME'
        value: containerRegistry.outputs.containerRegistryAdminUsername
      }
      {
        name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
        value: containerRegistry.outputs.containerRegistryAdminPassword
      }
    ]
  }
}

// Outputs
output appServiceUrl string = 'https://${appService.outputs.appServiceHostName}'
output appServiceName string = appService.outputs.appServiceName
output containerRegistryLoginServer string = containerRegistry.outputs.containerRegistryLoginServer
output keyVaultName string = keyVault.outputs.keyVaultName
output appInsightsName string = appInsights.outputs.appInsightsName
