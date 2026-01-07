# qops-hub-infra

Centralized Infrastructure as Code (IaC) and Azure DevOps pipeline templates for qops microservices.

## 📁 Repository Structure

```
qops-hub-infra/
├── bicep/                          # Bicep IaC templates and modules
│   ├── modules/                    # Reusable Bicep modules
│   │   ├── app-service-plan.bicep
│   │   ├── app-service.bicep
│   │   ├── storage-account.bicep
│   │   ├── key-vault.bicep
│   │   ├── container-registry.bicep
│   │   ├── log-analytics.bicep
│   │   └── app-insights.bicep
│   ├── environments/               # Environment-specific parameters
│   │   ├── dev.parameters.json
│   │   ├── test.parameters.json
│   │   └── prod.parameters.json
│   ├── shared/                     # Shared configurations
│   │   ├── tags.bicep             # Standardized tagging
│   │   ├── naming.bicep           # Naming conventions
│   │   ├── parameters.bicep       # Common parameters
│   │   └── outputs.bicep          # Output patterns
│   ├── main-webapp.bicep          # Web application template
│   ├── main-microservice.bicep    # Microservice template
│   └── README.md                  # Bicep documentation
├── pipelines/                      # Azure DevOps pipeline templates
│   ├── templates/                  # Reusable pipeline steps
│   │   ├── build-dotnet.yml
│   │   ├── build-node.yml
│   │   ├── build-docker.yml
│   │   ├── deploy-bicep.yml
│   │   ├── deploy-app-service.yml
│   │   └── job-build-deploy.yml
│   └── examples/                   # Example pipeline configurations
│       ├── azure-pipelines-dotnet.yml
│       ├── azure-pipelines-node.yml
│       └── azure-pipelines-docker.yml
├── docs/                           # Additional documentation
│   ├── architecture.md
│   ├── getting-started.md
│   └── best-practices.md
└── README.md                       # This file
```

## 🚀 Quick Start

### For New Microservices

1. **Copy Example Pipeline**
   ```bash
   # Choose the appropriate example for your technology stack
   cp azure-pipelines-dotnet.yml your-repo/azure-pipelines.yml
   # or
   cp azure-pipelines-node.yml your-repo/azure-pipelines.yml
   # or
   cp azure-pipelines-docker.yml your-repo/azure-pipelines.yml
   ```

2. **Customize Variables**
   Edit the copied pipeline file and update:
   - `azureSubscription`: Your Azure service connection name
   - `workloadName`: Your application/service name
   - Other environment-specific variables

3. **Reference This Repository**
   The pipeline already includes:
   ```yaml
   resources:
     repositories:
       - repository: qops-hub-infra
         type: github
         name: johanpearson/qops-hub-infra
         ref: main
   ```

4. **Commit and Push**
   The pipeline will automatically run on push to main or develop branches.

### For Infrastructure Deployment

1. **Choose a Template**
   - `bicep/main-webapp.bicep` - For web applications
   - `bicep/main-microservice.bicep` - For containerized services

2. **Customize Parameters**
   Create or modify environment parameter files:
   ```json
   {
     "parameters": {
       "environment": { "value": "dev" },
       "workloadName": { "value": "myapp" }
     }
   }
   ```

3. **Deploy**
   ```bash
   az deployment group create \
     --resource-group rg-myapp-dev-weu-001 \
     --template-file bicep/main-webapp.bicep \
     --parameters bicep/environments/dev.parameters.json
   ```

## 📖 Documentation

- **[Bicep README](bicep/README.md)** - Detailed Bicep module documentation and deployment guide
- **[Architecture Overview](docs/architecture.md)** - Infrastructure architecture and design decisions
- **[Getting Started Guide](docs/getting-started.md)** - Step-by-step setup instructions
- **[Best Practices](docs/best-practices.md)** - Recommended patterns and practices

## 🏗️ Key Features

### Infrastructure as Code (Bicep)

- ✅ **Modular Design**: Reusable modules for common Azure resources
- ✅ **Consistent Naming**: CAF-compliant naming conventions
- ✅ **Standardized Tags**: Automatic resource tagging for governance
- ✅ **Environment Separation**: Dedicated parameter files per environment
- ✅ **Security First**: Built-in security best practices (HTTPS, TLS 1.2, etc.)

### Azure Pipeline Templates

- ✅ **.NET Support**: Build and test .NET applications
- ✅ **Node.js Support**: Build and test Node.js applications
- ✅ **Docker Support**: Build and push container images
- ✅ **Infrastructure Deployment**: Automated Bicep deployments
- ✅ **Multi-Stage Pipelines**: Separate build and deployment stages
- ✅ **Environment Promotion**: Dev → Test → Prod workflow

## 🔧 Available Bicep Modules

| Module | Description | Key Features |
|--------|-------------|--------------|
| `app-service-plan.bicep` | App Service Plan | Linux/Windows, configurable SKU |
| `app-service.bicep` | Web App | Managed identity, App Insights integration |
| `storage-account.bicep` | Storage Account | Multiple SKUs, blob retention |
| `key-vault.bicep` | Key Vault | RBAC, soft delete, purge protection |
| `container-registry.bicep` | Container Registry | Admin access, image retention |
| `log-analytics.bicep` | Log Analytics | Centralized logging workspace |
| `app-insights.bicep` | Application Insights | Application performance monitoring |

## 📋 Available Pipeline Templates

| Template | Purpose | Technology |
|----------|---------|------------|
| `build-dotnet.yml` | Build .NET apps | .NET Core/8+ |
| `build-node.yml` | Build Node.js apps | Node.js 18+ |
| `build-docker.yml` | Build Docker images | Docker |
| `deploy-bicep.yml` | Deploy infrastructure | Bicep/ARM |
| `deploy-app-service.yml` | Deploy to App Service | Azure App Service |

## 🔐 Prerequisites

### Azure Resources
- Azure subscription with appropriate permissions
- Azure DevOps organization and project
- Service connection to Azure (Service Principal)

### Local Development
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [Bicep CLI](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install) (or use `az bicep`)
- Git

## 🎯 Usage Examples

### Example 1: Deploy a .NET Web Application

```yaml
# In your microservice repo: azure-pipelines.yml
trigger:
  branches:
    include: [main]

variables:
  workloadName: 'mywebapp'

stages:
  - stage: Build
    jobs:
      - job: Build
        steps:
          - template: templates/build-dotnet.yml@qops-hub-infra
            parameters:
              dotnetVersion: '8.x'

  - stage: Deploy
    jobs:
      - deployment: Infrastructure
        steps:
          - template: pipelines/templates/deploy-bicep.yml@qops-hub-infra
            parameters:
              azureSubscription: 'MyAzureConnection'
              resourceGroupName: 'rg-$(workloadName)-dev-weu-001'
              templateFile: 'qops-hub-infra/bicep/main-webapp.bicep'

resources:
  repositories:
    - repository: qops-hub-infra
      type: github
      name: johanpearson/qops-hub-infra
```

### Example 2: Deploy a Containerized Microservice

```yaml
# In your microservice repo: azure-pipelines.yml
stages:
  - stage: Build
    jobs:
      - job: Docker
        steps:
          - template: templates/build-docker.yml@qops-hub-infra
            parameters:
              containerRegistry: 'MyACR'
              repository: 'my-service'
              tags: ['$(Build.BuildId)', 'latest']

  - stage: Deploy
    jobs:
      - deployment: Infrastructure
        steps:
          - template: pipelines/templates/deploy-bicep.yml@qops-hub-infra
            parameters:
              templateFile: 'qops-hub-infra/bicep/main-microservice.bicep'

resources:
  repositories:
    - repository: qops-hub-infra
      type: github
      name: johanpearson/qops-hub-infra
```

## 🔄 Updating Templates

When templates in this repository are updated:

1. **Automatic**: Pipelines using `ref: main` will automatically use the latest version
2. **Versioned**: Create tags/releases for stable versions and reference specific tags:
   ```yaml
   resources:
     repositories:
       - repository: qops-hub-infra
         type: github
         name: johanpearson/qops-hub-infra
         ref: refs/tags/v1.0.0
   ```

## 🤝 Contributing

To add new modules or templates:

1. Create a new branch
2. Add your module/template following existing patterns
3. Update relevant documentation
4. Test thoroughly
5. Create a pull request

## 📝 Naming Conventions

All resources follow Microsoft Cloud Adoption Framework naming conventions:

**Format**: `{resource-type}-{workload}-{environment}-{region}-{instance}`

**Examples**:
- Resource Group: `rg-myapp-dev-weu-001`
- App Service: `app-myapp-dev-weu-001`
- Storage Account: `stmyappdev001` (no hyphens)
- Key Vault: `kv-myapp-dev-001`

## 🏷️ Standard Tags

All resources are automatically tagged with:
- `Environment`: dev/test/staging/prod
- `Application`: Application name
- `ManagedBy`: Bicep
- `DeployedAt`: Deployment timestamp
- `CostCenter`: (optional) Cost center
- `Owner`: (optional) Owner/team

## 🛟 Support and Issues

For questions or issues:
1. Check the documentation in `/docs`
2. Review existing examples in `/pipelines/examples`
3. Create an issue in this repository

## 📜 License

This infrastructure repository is for internal qops use.

## 🔗 Related Resources

- [Azure Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure DevOps Pipeline Documentation](https://docs.microsoft.com/azure/devops/pipelines/)
- [Microsoft Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/)
- [Azure Naming Conventions](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)