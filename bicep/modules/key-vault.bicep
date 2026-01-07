// Key Vault Module
// Creates an Azure Key Vault with configurable access policies

@description('Location for the Key Vault')
param location string = resourceGroup().location

@description('Name of the Key Vault (must be globally unique, 3-24 alphanumeric and hyphens)')
@minLength(3)
@maxLength(24)
param keyVaultName string

@description('Resource tags')
param tags object = {}

@description('SKU name')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('Enable Azure RBAC authorization')
param enableRbacAuthorization bool = true

@description('Enable soft delete')
param enableSoftDelete bool = true

@description('Soft delete retention in days')
@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 90

@description('Enable purge protection')
param enablePurgeProtection bool = true

@description('Object IDs to grant access (for access policies mode)')
param accessPolicyObjectIds array = []

// Create Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: skuName
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    accessPolicies: [for objectId in accessPolicyObjectIds: {
      tenantId: subscription().tenantId
      objectId: objectId
      permissions: {
        keys: [
          'get'
          'list'
        ]
        secrets: [
          'get'
          'list'
        ]
        certificates: [
          'get'
          'list'
        ]
      }
    }]
  }
}

// Outputs
output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
