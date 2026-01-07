// Application Insights Module
// Creates an Azure Application Insights instance for application monitoring

@description('Location for Application Insights')
param location string = resourceGroup().location

@description('Name of the Application Insights instance')
param appInsightsName string

@description('Resource tags')
param tags object = {}

@description('Log Analytics workspace ID')
param logAnalyticsWorkspaceId string

@description('Application type')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

@description('Retention in days')
@minValue(30)
@maxValue(730)
param retentionInDays int = 90

// Create Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: applicationType
  properties: {
    Application_Type: applicationType
    WorkspaceResourceId: logAnalyticsWorkspaceId
    RetentionInDays: retentionInDays
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Outputs
output appInsightsId string = appInsights.id
output appInsightsName string = appInsights.name
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString
