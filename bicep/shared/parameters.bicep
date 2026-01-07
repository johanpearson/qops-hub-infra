// Shared parameter definitions and common configurations
// This module provides common parameter types and default values

// Common location mappings
var locationMappings = {
  westeurope: 'weu'
  northeurope: 'neu'
  eastus: 'eus'
  eastus2: 'eus2'
  westus: 'wus'
  westus2: 'wus2'
  centralus: 'cus'
}

// SKU configurations for common services
var appServicePlanSkus = {
  free: {
    name: 'F1'
    tier: 'Free'
    capacity: 1
  }
  basic: {
    name: 'B1'
    tier: 'Basic'
    capacity: 1
  }
  standard: {
    name: 'S1'
    tier: 'Standard'
    capacity: 1
  }
  premium: {
    name: 'P1v2'
    tier: 'PremiumV2'
    capacity: 1
  }
}

var sqlDatabaseSkus = {
  basic: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  standard: {
    name: 'S0'
    tier: 'Standard'
    capacity: 10
  }
  premium: {
    name: 'P1'
    tier: 'Premium'
    capacity: 125
  }
}

var storageSku = {
  standard: 'Standard_LRS'
  premium: 'Premium_LRS'
  zoneRedundant: 'Standard_ZRS'
  geoRedundant: 'Standard_GRS'
}

// Environment-specific configurations
var environmentConfigs = {
  dev: {
    sku: 'basic'
    enableBackup: false
    enableMonitoring: true
    enableAutoScale: false
  }
  test: {
    sku: 'basic'
    enableBackup: false
    enableMonitoring: true
    enableAutoScale: false
  }
  staging: {
    sku: 'standard'
    enableBackup: true
    enableMonitoring: true
    enableAutoScale: false
  }
  prod: {
    sku: 'premium'
    enableBackup: true
    enableMonitoring: true
    enableAutoScale: true
  }
}

// Export configurations
output locationMappings object = locationMappings
output appServicePlanSkus object = appServicePlanSkus
output sqlDatabaseSkus object = sqlDatabaseSkus
output storageSku object = storageSku
output environmentConfigs object = environmentConfigs
