// App Service (Web App) Module
// Creates an Azure App Service with optional Application Insights integration

@description('Location for the App Service')
param location string = resourceGroup().location

@description('Name of the App Service')
param appServiceName string

@description('App Service Plan ID')
param appServicePlanId string

@description('Resource tags')
param tags object = {}

@description('Application Insights Instrumentation Key (optional)')
@secure()
param appInsightsInstrumentationKey string = ''

@description('Application Insights Connection String (optional)')
@secure()
param appInsightsConnectionString string = ''

@description('App settings for the application')
param appSettings array = []

@description('Enable managed identity')
param enableManagedIdentity bool = true

@description('Runtime stack (e.g., DOTNETCORE|8.0, NODE|18-lts, PYTHON|3.11)')
param linuxFxVersion string = ''

// Create App Service
resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: appServiceName
  location: location
  tags: tags
  kind: 'app,linux'
  identity: enableManagedIdentity ? {
    type: 'SystemAssigned'
  } : null
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
      appSettings: union(
        appSettings,
        !empty(appInsightsInstrumentationKey) ? [
          {
            name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
            value: appInsightsInstrumentationKey
          }
          {
            name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
            value: appInsightsConnectionString
          }
          {
            name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
            value: '~3'
          }
        ] : []
      )
    }
    httpsOnly: true
    clientAffinityEnabled: false
  }
}

// Outputs
output appServiceId string = appService.id
output appServiceName string = appService.name
output appServiceHostName string = appService.properties.defaultHostName
output appServicePrincipalId string = enableManagedIdentity ? appService.identity.principalId : ''
