// Shared output definitions for common resource outputs
// This file documents standard output patterns to use across modules

/*
Standard output patterns:

1. Resource ID:
   output resourceId string = resource.id

2. Resource Name:
   output resourceName string = resource.name

3. Connection Strings (sensitive):
   @secure()
   output connectionString string = 'connection-string-value'

4. Endpoints:
   output endpoint string = resource.properties.endpoint

5. Principal ID (for Managed Identity):
   output principalId string = resource.identity.principalId

6. Key Vault Reference:
   output keyVaultReference string = '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${secretName})'

Example module outputs:

// App Service
output appServiceId string = appService.id
output appServiceName string = appService.name
output appServiceHostName string = appService.properties.defaultHostName
output appServicePrincipalId string = appService.identity.principalId

// Storage Account
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output storageAccountPrimaryEndpoint string = storageAccount.properties.primaryEndpoints.blob
@secure()
output storageAccountKey string = storageAccount.listKeys().keys[0].value

// Key Vault
output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri

// SQL Database
output sqlServerId string = sqlServer.id
output sqlServerName string = sqlServer.name
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output sqlDatabaseName string = sqlDatabase.name
@secure()
output sqlConnectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Database=${sqlDatabase.name};'

// Container Registry
output containerRegistryId string = containerRegistry.id
output containerRegistryName string = containerRegistry.name
output containerRegistryLoginServer string = containerRegistry.properties.loginServer

// Log Analytics
output logAnalyticsWorkspaceId string = logAnalytics.id
output logAnalyticsWorkspaceName string = logAnalytics.name
output logAnalyticsCustomerId string = logAnalytics.properties.customerId

// Application Insights
output appInsightsId string = appInsights.id
output appInsightsName string = appInsights.name
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString
*/
