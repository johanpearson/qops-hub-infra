// Example: Web Application Deployment
// This example deploys a complete web application stack including:
// - App Service Plan
// - App Service (Web App)
// - Application Insights
// - Log Analytics Workspace
// - Storage Account
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

// Deploy Storage Account
module storageAccount 'modules/storage-account.bicep' = {
  name: 'storageAccount'
  params: {
    location: location
    storageAccountName: naming.outputs.storageAccount
    tags: tagging.outputs.tags
    sku: 'Standard_LRS'
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

// Deploy App Service
module appService 'modules/app-service.bicep' = {
  name: 'appService'
  params: {
    location: location
    appServiceName: naming.outputs.appService
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    tags: tagging.outputs.tags
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
    appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
    linuxFxVersion: 'DOTNETCORE|8.0'
    appSettings: [
      {
        name: 'WEBSITE_RUN_FROM_PACKAGE'
        value: '1'
      }
    ]
  }
}

// Outputs
output appServiceUrl string = 'https://${appService.outputs.appServiceHostName}'
output appServiceName string = appService.outputs.appServiceName
output keyVaultName string = keyVault.outputs.keyVaultName
output storageAccountName string = storageAccount.outputs.storageAccountName
output appInsightsName string = appInsights.outputs.appInsightsName
