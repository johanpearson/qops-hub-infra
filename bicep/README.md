# Bicep Infrastructure as Code

This directory contains reusable Bicep modules and templates for deploying Azure infrastructure across your qops projects.

## Directory Structure

```
bicep/
├── modules/              # Reusable Bicep modules for Azure resources
├── environments/         # Environment-specific parameter files
├── shared/              # Shared configurations (tags, naming, parameters)
├── main-*.bicep         # Example deployment templates
└── README.md            # This file
```

## Shared Components

### Naming Conventions (`shared/naming.bicep`)
Provides consistent naming across all Azure resources following Microsoft Cloud Adoption Framework (CAF) best practices.

**Usage:**
```bicep
module naming 'shared/naming.bicep' = {
  name: 'naming'
  params: {
    environment: 'dev'
    workloadName: 'myapp'
    regionCode: 'weu'
  }
}

// Use outputs
var storageAccountName = naming.outputs.storageAccount
var appServiceName = naming.outputs.appService
```

**Naming Format:** `{prefix}-{workload}-{environment}-{region}-{instance}`

Example: `app-myapp-dev-weu-001`

### Tags (`shared/tags.bicep`)
Standardized tagging for all Azure resources to support governance, cost management, and compliance.

**Usage:**
```bicep
module tagging 'shared/tags.bicep' = {
  name: 'tagging'
  params: {
    environment: 'dev'
    applicationName: 'MyApplication'
    costCenter: 'Engineering'
    owner: 'DevTeam'
  }
}

// Apply tags to resources
tags: tagging.outputs.tags
```

**Standard Tags:**
- Environment
- Application
- ManagedBy
- DeployedAt
- CostCenter (optional)
- Owner (optional)

### Parameters (`shared/parameters.bicep`)
Common parameter definitions, SKU configurations, and environment-specific settings.

## Available Modules

### App Service Plan (`modules/app-service-plan.bicep`)
Creates an Azure App Service Plan with configurable SKU.

**Parameters:**
- `location`: Azure region
- `appServicePlanName`: Name of the plan
- `sku`: SKU configuration (name, tier, capacity)
- `kind`: Linux or Windows
- `tags`: Resource tags

**Outputs:**
- `appServicePlanId`: Resource ID
- `appServicePlanName`: Resource name

### App Service (`modules/app-service.bicep`)
Creates an Azure App Service (Web App) with optional Application Insights integration.

**Parameters:**
- `location`: Azure region
- `appServiceName`: Name of the app service
- `appServicePlanId`: Associated App Service Plan ID
- `appInsightsInstrumentationKey`: (optional) Application Insights key
- `linuxFxVersion`: Runtime stack
- `appSettings`: Application settings array
- `tags`: Resource tags

**Outputs:**
- `appServiceId`: Resource ID
- `appServiceName`: Resource name
- `appServiceHostName`: Default hostname
- `appServicePrincipalId`: Managed identity principal ID

### Storage Account (`modules/storage-account.bicep`)
Creates an Azure Storage Account with configurable SKU.

**Parameters:**
- `location`: Azure region
- `storageAccountName`: Globally unique name (3-24 chars)
- `sku`: Storage SKU (Standard_LRS, Standard_GRS, etc.)
- `kind`: Storage type (StorageV2 recommended)
- `tags`: Resource tags

**Outputs:**
- `storageAccountId`: Resource ID
- `storageAccountName`: Resource name
- `storageAccountPrimaryEndpoint`: Blob endpoint
- `storageAccountKey`: Primary access key (secure)
- `storageAccountConnectionString`: Connection string

### Key Vault (`modules/key-vault.bicep`)
Creates an Azure Key Vault for secrets management.

**Parameters:**
- `location`: Azure region
- `keyVaultName`: Globally unique name (3-24 chars)
- `skuName`: standard or premium
- `enableRbacAuthorization`: Use Azure RBAC (recommended)
- `tags`: Resource tags

**Outputs:**
- `keyVaultId`: Resource ID
- `keyVaultName`: Resource name
- `keyVaultUri`: Vault URI

### Container Registry (`modules/container-registry.bicep`)
Creates an Azure Container Registry for Docker images.

**Parameters:**
- `location`: Azure region
- `containerRegistryName`: Globally unique name (5-50 chars)
- `sku`: Basic, Standard, or Premium
- `adminUserEnabled`: Enable admin credentials
- `tags`: Resource tags

**Outputs:**
- `containerRegistryId`: Resource ID
- `containerRegistryName`: Resource name
- `containerRegistryLoginServer`: Login server URL
- `containerRegistryAdminUsername`: Admin username (if enabled)
- `containerRegistryAdminPassword`: Admin password (if enabled)

### Log Analytics Workspace (`modules/log-analytics.bicep`)
Creates a Log Analytics workspace for centralized logging.

**Parameters:**
- `location`: Azure region
- `logAnalyticsName`: Workspace name
- `sku`: Pricing tier (PerGB2018 recommended)
- `retentionInDays`: Data retention (30-730 days)
- `tags`: Resource tags

**Outputs:**
- `logAnalyticsWorkspaceId`: Resource ID
- `logAnalyticsWorkspaceName`: Resource name
- `logAnalyticsCustomerId`: Customer ID

### Application Insights (`modules/app-insights.bicep`)
Creates Application Insights for application monitoring.

**Parameters:**
- `location`: Azure region
- `appInsightsName`: Instance name
- `logAnalyticsWorkspaceId`: Associated Log Analytics workspace
- `applicationType`: web or other
- `tags`: Resource tags

**Outputs:**
- `appInsightsId`: Resource ID
- `appInsightsName`: Resource name
- `appInsightsInstrumentationKey`: Instrumentation key
- `appInsightsConnectionString`: Connection string

## Example Deployments

### Example 1: Web Application Stack (`main-webapp.bicep`)
Deploys a complete web application infrastructure:
- App Service Plan
- App Service
- Application Insights
- Log Analytics Workspace
- Storage Account
- Key Vault

### Example 2: Containerized Microservice (`main-microservice.bicep`)
Deploys infrastructure for a containerized microservice:
- Container Registry
- App Service Plan (Linux)
- App Service with container support
- Application Insights
- Log Analytics Workspace
- Key Vault

## How to Deploy Infrastructure

### Prerequisites

1. **Azure CLI** - Install from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
2. **Bicep CLI** - Install with: `az bicep install`
3. **Azure Subscription** - Active Azure subscription with appropriate permissions

### Login to Azure

```bash
az login
az account set --subscription <subscription-id>
```

### Deployment Steps

#### 1. Create Resource Group

```bash
az group create \
  --name rg-myapp-dev-weu-001 \
  --location westeurope
```

#### 2. Validate Deployment

```bash
az deployment group validate \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/dev.parameters.json
```

#### 3. What-If Analysis (Optional but Recommended)

```bash
az deployment group what-if \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/dev.parameters.json
```

#### 4. Deploy Infrastructure

```bash
az deployment group create \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/dev.parameters.json \
  --name deployment-$(date +%Y%m%d-%H%M%S)
```

#### 5. View Deployment Outputs

```bash
az deployment group show \
  --resource-group rg-myapp-dev-weu-001 \
  --name <deployment-name> \
  --query properties.outputs
```

### Deploy Different Environments

**Development:**
```bash
az deployment group create \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/dev.parameters.json
```

**Test:**
```bash
az deployment group create \
  --resource-group rg-myapp-test-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/test.parameters.json
```

**Production:**
```bash
az deployment group create \
  --resource-group rg-myapp-prod-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/prod.parameters.json
```

## Using Modules in Your Project

### Option 1: Local Module Reference

Copy the modules to your repository and reference them locally:

```bicep
module appService '../qops-hub-infra/bicep/modules/app-service.bicep' = {
  name: 'appService'
  params: {
    // parameters
  }
}
```

### Option 2: Template Specs (Recommended)

Publish modules as Template Specs for centralized management:

```bash
# Create Template Spec
az ts create \
  --name app-service-module \
  --version 1.0.0 \
  --resource-group rg-template-specs \
  --location westeurope \
  --template-file bicep/modules/app-service.bicep

# Use in deployments
module appService 'ts:<subscription-id>/rg-template-specs/app-service-module:1.0.0' = {
  name: 'appService'
  params: {
    // parameters
  }
}
```

## Customization

### Customize Parameter Files

Edit the parameter files in `bicep/environments/` to match your requirements:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environment": {
      "value": "dev"
    },
    "workloadName": {
      "value": "myapp"
    },
    "location": {
      "value": "westeurope"
    }
  }
}
```

### Create Custom Main Templates

Use the example templates as a starting point:

1. Copy an example: `cp main-webapp.bicep main-myservice.bicep`
2. Modify to include only required resources
3. Add/remove modules as needed
4. Update parameters

## Best Practices

1. **Use Shared Modules**: Always use the shared naming and tagging modules for consistency
2. **Parameter Files**: Create separate parameter files for each environment
3. **Validation**: Always run `validate` and `what-if` before deploying
4. **Naming**: Follow the established naming conventions
5. **Tags**: Apply standard tags to all resources
6. **Secrets**: Store sensitive values in Key Vault, never in parameter files
7. **RBAC**: Use Azure RBAC for Key Vault instead of access policies
8. **Managed Identities**: Enable managed identities for App Services
9. **HTTPS Only**: Always enable HTTPS only for web applications
10. **Monitoring**: Include Application Insights and Log Analytics in all deployments

## Troubleshooting

### Common Issues

1. **Name Already Exists**
   - Storage accounts and key vaults must have globally unique names
   - Add a unique suffix or use different region codes

2. **Insufficient Permissions**
   - Ensure you have Contributor or Owner role on the subscription
   - Check RBAC assignments with: `az role assignment list --assignee <user-id>`

3. **Validation Errors**
   - Review error messages carefully
   - Check parameter types and constraints
   - Verify resource dependencies

4. **Deployment Timeout**
   - Large deployments may take time
   - Monitor deployment progress in Azure Portal
   - Check activity logs for detailed information

### Useful Commands

```bash
# List deployments
az deployment group list --resource-group <rg-name>

# Show deployment details
az deployment group show --resource-group <rg-name> --name <deployment-name>

# View deployment operations
az deployment operation group list --resource-group <rg-name> --name <deployment-name>

# Delete deployment
az deployment group delete --resource-group <rg-name> --name <deployment-name>

# Export template from existing resources
az group export --resource-group <rg-name> --include-parameter-default-value
```

## Support

For issues or questions:
1. Check the Azure Bicep documentation: https://docs.microsoft.com/azure/azure-resource-manager/bicep/
2. Review Azure resource provider schemas: https://docs.microsoft.com/azure/templates/
3. Create an issue in this repository

## Version History

- **v1.0.0** - Initial release with core modules and examples
