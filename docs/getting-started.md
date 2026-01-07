# Getting Started Guide

This guide will walk you through setting up and using the qops-hub-infra repository for your microservices.

## Prerequisites

Before you begin, ensure you have:

### Required Tools
- **Git**: For version control
- **Azure CLI**: `az` command-line tool ([Install](https://docs.microsoft.com/cli/azure/install-azure-cli))
- **Bicep CLI**: `az bicep install` (or comes with Azure CLI)
- **Azure DevOps Access**: Access to your organization and project

### Azure Resources
- **Azure Subscription**: Active subscription with appropriate permissions
- **Azure DevOps Organization**: Your organization URL
- **Service Connection**: Service Principal with Contributor role

### Permissions
- **Azure**: Contributor or Owner on the subscription/resource group
- **Azure DevOps**: Build Administrator or Project Administrator

## Step 1: Set Up Azure Environment

### 1.1 Login to Azure

```bash
# Login to Azure
az login

# List available subscriptions
az account list --output table

# Set the subscription you want to use
az account set --subscription "Your Subscription Name or ID"

# Verify the current subscription
az account show
```

### 1.2 Create a Service Principal for Azure DevOps

```bash
# Create a service principal
az ad sp create-for-rbac \
  --name "qops-devops-sp" \
  --role Contributor \
  --scopes /subscriptions/{subscription-id}

# Output will include:
# - appId (clientId)
# - password (clientSecret)
# - tenant
# Save these values securely!
```

## Step 2: Configure Azure DevOps

### 2.1 Create a Service Connection

1. Navigate to your Azure DevOps project
2. Go to **Project Settings** → **Service connections**
3. Click **New service connection**
4. Select **Azure Resource Manager**
5. Choose **Service principal (manual)**
6. Enter the details from Step 1.2:
   - **Subscription ID**: Your Azure subscription ID
   - **Subscription Name**: Display name
   - **Service Principal Id**: The `appId` from above
   - **Service Principal Key**: The `password` from above
   - **Tenant ID**: The `tenant` from above
7. Name it (e.g., "Azure-Production")
8. Click **Verify and save**

### 2.2 Add Repository to Azure DevOps

1. In your Azure DevOps project, go to **Project Settings** → **Service connections**
2. Create a new service connection for GitHub:
   - Select **GitHub**
   - Authorize Azure DevOps to access your GitHub account
   - Select the repository: `johanpearson/qops-hub-infra`

## Step 3: Your First Deployment (CLI)

### 3.1 Clone the Repository

```bash
# Clone the repository
git clone https://github.com/johanpearson/qops-hub-infra.git
cd qops-hub-infra
```

### 3.2 Review and Customize Parameters

```bash
# View the development parameters
cat bicep/environments/dev.parameters.json

# Edit as needed
nano bicep/environments/dev.parameters.json
```

Update the values:
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environment": {
      "value": "dev"
    },
    "workloadName": {
      "value": "myapp"  // Change this to your app name
    },
    "location": {
      "value": "westeurope"
    },
    "regionCode": {
      "value": "weu"
    },
    "applicationName": {
      "value": "MyApplication"
    },
    "costCenter": {
      "value": "Engineering"
    },
    "owner": {
      "value": "YourTeam"  // Change this to your team name
    }
  }
}
```

### 3.3 Create Resource Group

```bash
# Create a resource group for development
az group create \
  --name rg-myapp-dev-weu-001 \
  --location westeurope \
  --tags Environment=dev Application=MyApp
```

### 3.4 Validate the Deployment

```bash
# Validate the Bicep template
az deployment group validate \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/dev.parameters.json
```

### 3.5 Preview Changes with What-If

```bash
# See what would be deployed
az deployment group what-if \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/dev.parameters.json
```

### 3.6 Deploy Infrastructure

```bash
# Deploy the infrastructure
az deployment group create \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/dev.parameters.json \
  --name deployment-$(date +%Y%m%d-%H%M%S)
```

### 3.7 View Deployment Outputs

```bash
# Get deployment outputs
az deployment group show \
  --resource-group rg-myapp-dev-weu-001 \
  --name deployment-YYYYMMDD-HHMMSS \
  --query properties.outputs
```

## Step 4: Set Up Your Microservice Repository

### 4.1 Copy Example Pipeline

Choose the appropriate pipeline template for your technology:

```bash
# For .NET applications
cp qops-hub-infra/pipelines/examples/azure-pipelines-dotnet.yml \
   your-microservice/azure-pipelines.yml

# For Node.js applications
cp qops-hub-infra/pipelines/examples/azure-pipelines-node.yml \
   your-microservice/azure-pipelines.yml

# For Docker-based applications
cp qops-hub-infra/pipelines/examples/azure-pipelines-docker.yml \
   your-microservice/azure-pipelines.yml
```

### 4.2 Customize the Pipeline

Edit `your-microservice/azure-pipelines.yml`:

```yaml
variables:
  - name: azureSubscription
    value: 'Azure-Production'  # Match your service connection name
  - name: workloadName
    value: 'myapp'  # Your application identifier
  - name: containerRegistryName
    value: 'crmyappdev001'  # If using containers

# Update repository reference if needed
resources:
  repositories:
    - repository: qops-hub-infra
      type: github
      name: johanpearson/qops-hub-infra
      ref: main  # or specific version tag
```

### 4.3 Create Azure Pipeline

1. Go to your Azure DevOps project
2. Navigate to **Pipelines** → **Pipelines**
3. Click **New pipeline**
4. Select **Azure Repos Git** or **GitHub**
5. Select your microservice repository
6. Select **Existing Azure Pipelines YAML file**
7. Select `/azure-pipelines.yml`
8. Click **Run**

## Step 5: Deploy Your Microservice

### 5.1 First Build

Once you've created the pipeline:

1. The pipeline will trigger automatically on push to `main` or `develop`
2. Monitor the pipeline execution in Azure DevOps
3. View logs for each stage and step

### 5.2 Verify Deployment

```bash
# Check deployed resources
az resource list \
  --resource-group rg-myapp-dev-weu-001 \
  --output table

# Check App Service URL
az webapp show \
  --name app-myapp-dev-weu-001 \
  --resource-group rg-myapp-dev-weu-001 \
  --query defaultHostName \
  --output tsv
```

### 5.3 Test Your Application

```bash
# Test the deployed application
curl https://app-myapp-dev-weu-001.azurewebsites.net

# Or open in browser
open https://app-myapp-dev-weu-001.azurewebsites.net
```

## Step 6: Deploy to Additional Environments

### 6.1 Create Test Environment

```bash
# Create test resource group
az group create \
  --name rg-myapp-test-weu-001 \
  --location westeurope \
  --tags Environment=test Application=MyApp

# Deploy test infrastructure
az deployment group create \
  --resource-group rg-myapp-test-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/test.parameters.json
```

### 6.2 Create Production Environment

```bash
# Create production resource group
az group create \
  --name rg-myapp-prod-weu-001 \
  --location westeurope \
  --tags Environment=prod Application=MyApp

# Deploy production infrastructure
az deployment group create \
  --resource-group rg-myapp-prod-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/prod.parameters.json
```

### 6.3 Configure Pipeline Environments

1. In Azure DevOps, go to **Pipelines** → **Environments**
2. Create environments: `dev`, `test`, `prod`
3. Add approvals for `prod` environment:
   - Click on the `prod` environment
   - Click **Approvals and checks**
   - Add **Approvals** check
   - Specify approvers

## Common Scenarios

### Scenario 1: Add a New Bicep Module

```bash
# Create a new module
cd qops-hub-infra/bicep/modules
nano my-new-module.bicep

# Use in your main template
# Reference it in main-webapp.bicep or main-microservice.bicep
```

### Scenario 2: Update Existing Infrastructure

```bash
# Make changes to your Bicep files
nano bicep/main-webapp.bicep

# Validate changes
az deployment group what-if \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/dev.parameters.json

# Deploy updates
az deployment group create \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/dev.parameters.json
```

### Scenario 3: Add Application Settings

```yaml
# In your azure-pipelines.yml
- template: pipelines/templates/deploy-app-service.yml@qops-hub-infra
  parameters:
    azureSubscription: $(azureSubscription)
    appServiceName: 'app-$(workloadName)-dev-weu-001'
    artifactName: 'drop'
    appSettings: |
      -ASPNETCORE_ENVIRONMENT Development
      -CustomSetting Value1
      -AnotherSetting Value2
```

### Scenario 4: Use Key Vault Secrets

```bash
# Add a secret to Key Vault
az keyvault secret set \
  --vault-name kv-myapp-dev-001 \
  --name ConnectionString \
  --value "your-connection-string"

# Reference in App Service (via pipeline or Bicep)
# In App Service settings:
# @Microsoft.KeyVault(VaultName=kv-myapp-dev-001;SecretName=ConnectionString)
```

## Troubleshooting

### Issue: Deployment Validation Fails

```bash
# Check for detailed errors
az deployment group validate \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/dev.parameters.json \
  --debug
```

### Issue: Resource Name Already Exists

Storage accounts and Key Vaults require globally unique names. Update your parameters:

```json
{
  "workloadName": {
    "value": "myapp2"  // Try a different name
  }
}
```

### Issue: Insufficient Permissions

```bash
# Check your current role
az role assignment list \
  --assignee $(az account show --query user.name -o tsv) \
  --all

# You need at least "Contributor" role
```

### Issue: Pipeline Fails to Find Template

Check your repository reference:
```yaml
resources:
  repositories:
    - repository: qops-hub-infra
      type: github
      name: johanpearson/qops-hub-infra
      ref: main  # Ensure this is correct
```

## Next Steps

- Read the [Architecture Documentation](architecture.md)
- Review [Best Practices](best-practices.md)
- Explore the [Bicep README](../bicep/README.md)
- Check example pipelines in `pipelines/examples/`

## Getting Help

If you encounter issues:
1. Check the documentation in `/docs`
2. Review the examples in `/pipelines/examples` and `/bicep`
3. Create an issue in the repository
4. Contact the platform team

## Useful Commands Cheat Sheet

```bash
# Azure CLI
az login
az account list
az account set --subscription "name"
az group create --name rg-name --location westeurope
az deployment group create --resource-group rg-name --template-file file.bicep
az deployment group what-if --resource-group rg-name --template-file file.bicep
az resource list --resource-group rg-name

# Bicep
az bicep build --file main.bicep
az bicep decompile --file template.json

# Git
git clone https://github.com/johanpearson/qops-hub-infra.git
git pull origin main
git checkout -b feature-branch
```

Congratulations! You're now ready to use qops-hub-infra for your microservices. 🎉
