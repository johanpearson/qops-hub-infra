// Shared tags configuration for all resources
// This module provides standardized tagging across all Azure resources

@description('Environment name (dev, test, staging, prod)')
param environment string

@description('Application or service name')
param applicationName string

@description('Cost center or department')
param costCenter string = ''

@description('Owner or team responsible')
param owner string = ''

@description('Additional custom tags')
param customTags object = {}

@description('Deployment timestamp')
param deploymentTimestamp string = utcNow('yyyy-MM-dd')

// Standard tags that should be applied to all resources
var standardTags = {
  Environment: environment
  Application: applicationName
  ManagedBy: 'Bicep'
  DeployedAt: deploymentTimestamp
}

// Optional tags (only included if values are provided)
var costCenterTag = !empty(costCenter) ? { CostCenter: costCenter } : {}
var ownerTag = !empty(owner) ? { Owner: owner } : {}

// Combine all tags
output tags object = union(standardTags, costCenterTag, ownerTag, customTags)
