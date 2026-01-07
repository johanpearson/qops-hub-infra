// Shared naming conventions for Azure resources
// This module provides consistent naming across all Azure resources
// Based on Microsoft Cloud Adoption Framework naming conventions

@description('Environment name (dev, test, staging, prod)')
@allowed([
  'dev'
  'test'
  'staging'
  'prod'
])
param environment string

@description('Application or workload name (short, 3-10 characters)')
@minLength(3)
@maxLength(10)
param workloadName string

@description('Azure region short code (e.g., weu for West Europe, eus for East US)')
param regionCode string = 'weu'

@description('Optional instance number for multiple deployments')
param instance string = '001'

// Resource type prefixes based on CAF recommendations
var resourceTypePrefixes = {
  resourceGroup: 'rg'
  storageAccount: 'st'
  appServicePlan: 'asp'
  appService: 'app'
  functionApp: 'func'
  keyVault: 'kv'
  containerRegistry: 'cr'
  logAnalytics: 'log'
  appInsights: 'appi'
  sqlServer: 'sql'
  sqlDatabase: 'sqldb'
  cosmosDb: 'cosmos'
  serviceBus: 'sb'
  eventHub: 'evh'
  containerApp: 'ca'
  containerAppEnv: 'cae'
  virtualNetwork: 'vnet'
  subnet: 'snet'
  networkSecurityGroup: 'nsg'
  publicIp: 'pip'
  loadBalancer: 'lb'
  managedIdentity: 'id'
}

// Generate standardized names
// Format: {prefix}-{workload}-{environment}-{region}-{instance}
output resourceGroup string = '${resourceTypePrefixes.resourceGroup}-${workloadName}-${environment}-${regionCode}-${instance}'
output storageAccount string = toLower(replace('${resourceTypePrefixes.storageAccount}${workloadName}${environment}${instance}', '-', ''))
output appServicePlan string = '${resourceTypePrefixes.appServicePlan}-${workloadName}-${environment}-${regionCode}-${instance}'
output appService string = '${resourceTypePrefixes.appService}-${workloadName}-${environment}-${regionCode}-${instance}'
output functionApp string = '${resourceTypePrefixes.functionApp}-${workloadName}-${environment}-${regionCode}-${instance}'
output keyVault string = toLower('${resourceTypePrefixes.keyVault}-${workloadName}-${environment}-${instance}')
output containerRegistry string = toLower(replace('${resourceTypePrefixes.containerRegistry}${workloadName}${environment}${instance}', '-', ''))
output logAnalytics string = '${resourceTypePrefixes.logAnalytics}-${workloadName}-${environment}-${regionCode}-${instance}'
output appInsights string = '${resourceTypePrefixes.appInsights}-${workloadName}-${environment}-${regionCode}-${instance}'
output sqlServer string = '${resourceTypePrefixes.sqlServer}-${workloadName}-${environment}-${regionCode}-${instance}'
output sqlDatabase string = '${resourceTypePrefixes.sqlDatabase}-${workloadName}-${environment}-${regionCode}-${instance}'
output cosmosDb string = '${resourceTypePrefixes.cosmosDb}-${workloadName}-${environment}-${regionCode}-${instance}'
output serviceBus string = '${resourceTypePrefixes.serviceBus}-${workloadName}-${environment}-${regionCode}-${instance}'
output eventHub string = '${resourceTypePrefixes.eventHub}-${workloadName}-${environment}-${regionCode}-${instance}'
output containerApp string = '${resourceTypePrefixes.containerApp}-${workloadName}-${environment}-${regionCode}-${instance}'
output containerAppEnv string = '${resourceTypePrefixes.containerAppEnv}-${workloadName}-${environment}-${regionCode}-${instance}'
output virtualNetwork string = '${resourceTypePrefixes.virtualNetwork}-${workloadName}-${environment}-${regionCode}-${instance}'
output subnet string = '${resourceTypePrefixes.subnet}-${workloadName}-${environment}-${regionCode}-${instance}'
output networkSecurityGroup string = '${resourceTypePrefixes.networkSecurityGroup}-${workloadName}-${environment}-${regionCode}-${instance}'
output publicIp string = '${resourceTypePrefixes.publicIp}-${workloadName}-${environment}-${regionCode}-${instance}'
output loadBalancer string = '${resourceTypePrefixes.loadBalancer}-${workloadName}-${environment}-${regionCode}-${instance}'
output managedIdentity string = '${resourceTypePrefixes.managedIdentity}-${workloadName}-${environment}-${regionCode}-${instance}'
