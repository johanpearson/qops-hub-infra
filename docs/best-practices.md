# Best Practices

This document outlines best practices for using the qops-hub-infra repository effectively and securely.

## Infrastructure as Code (Bicep)

### Module Design

#### ✅ DO
- **Keep modules focused**: Each module should handle a single resource type
- **Use parameters**: Make modules configurable with parameters
- **Document parameters**: Use `@description` for all parameters
- **Define constraints**: Use `@minLength`, `@maxLength`, `@allowed` where appropriate
- **Output key values**: Return resource IDs, names, and connection details
- **Use secure parameters**: Mark sensitive parameters with `@secure()`

```bicep
@description('Name of the storage account')
@minLength(3)
@maxLength(24)
param storageAccountName string

@secure()
@description('Storage account key')
param storageKey string
```

#### ❌ DON'T
- **Don't hardcode values**: Use parameters or variables
- **Don't create overly complex modules**: Break them down
- **Don't ignore naming conventions**: Follow the CAF standards
- **Don't skip validation**: Always use `validate` and `what-if`

### Resource Naming

#### ✅ DO
- **Use the naming module**: Always reference `shared/naming.bicep`
- **Follow CAF conventions**: Use the standard format
- **Be consistent**: Use the same pattern across all resources
- **Consider uniqueness**: Account for globally unique names (Storage, Key Vault)

```bicep
module naming 'shared/naming.bicep' = {
  name: 'naming'
  params: {
    environment: environment
    workloadName: workloadName
    regionCode: regionCode
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: naming.outputs.storageAccount
  // ...
}
```

#### ❌ DON'T
- **Don't use arbitrary names**: Always follow the convention
- **Don't mix naming styles**: Be consistent
- **Don't forget region codes**: Include them for clarity

### Tagging

#### ✅ DO
- **Use the tagging module**: Always reference `shared/tags.bicep`
- **Apply to all resources**: Every resource should be tagged
- **Include required tags**: Environment, Application, ManagedBy
- **Add optional metadata**: CostCenter, Owner when available

```bicep
module tagging 'shared/tags.bicep' = {
  name: 'tagging'
  params: {
    environment: environment
    applicationName: applicationName
    costCenter: costCenter
    owner: owner
  }
}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: appServiceName
  tags: tagging.outputs.tags
  // ...
}
```

#### ❌ DON'T
- **Don't skip tagging**: All resources need tags
- **Don't use inconsistent tag names**: Use the standard keys
- **Don't embed dates in tag values**: Use the automatic DeployedAt

### Security

#### ✅ DO
- **Enable HTTPS only**: Always set `httpsOnly: true`
- **Use minimum TLS 1.2**: Set `minTlsVersion: '1.2'`
- **Enable managed identities**: Use system-assigned identities
- **Use Azure RBAC**: Prefer RBAC over access policies
- **Store secrets in Key Vault**: Never in parameters or code
- **Enable soft delete**: For Key Vault and Storage
- **Disable public access**: Where not needed

```bicep
resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: appServiceName
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
  }
}
```

#### ❌ DON'T
- **Don't expose secrets**: Never output secrets in plain text
- **Don't allow HTTP**: Always enforce HTTPS
- **Don't use old TLS versions**: Minimum TLS 1.2
- **Don't hardcode credentials**: Use Key Vault or managed identities
- **Don't disable security features**: Unless absolutely necessary

### Parameter Files

#### ✅ DO
- **Create per-environment files**: One file per environment
- **Keep them minimal**: Only override necessary values
- **Version control them**: Check them into Git
- **Document deviations**: Explain non-standard values

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environment": {
      "value": "prod"
    },
    "workloadName": {
      "value": "myapp"
    }
  }
}
```

#### ❌ DON'T
- **Don't store secrets**: Use Key Vault references instead
- **Don't duplicate all parameters**: Only what's different
- **Don't use generic names**: Be specific to the environment

## Azure Pipelines

### Pipeline Structure

#### ✅ DO
- **Use multi-stage pipelines**: Separate build and deploy
- **Leverage templates**: Reference qops-hub-infra templates
- **Use environments**: Configure approvals and gates
- **Enable CI/CD**: Trigger on appropriate branches
- **Run tests**: Include unit and integration tests
- **Use variables**: For reusable values

```yaml
trigger:
  branches:
    include:
      - main
      - develop

variables:
  - name: azureSubscription
    value: 'Azure-Production'
  - name: workloadName
    value: 'myapp'

stages:
  - stage: Build
    jobs:
      - job: Build
        steps:
          - template: templates/build-dotnet.yml@qops-hub-infra
            parameters:
              dotnetVersion: '8.x'
```

#### ❌ DON'T
- **Don't skip stages**: Always build before deploy
- **Don't hardcode values**: Use variables or parameters
- **Don't ignore test failures**: Fail the pipeline on errors
- **Don't deploy on every commit**: Use branch filters

### Security in Pipelines

#### ✅ DO
- **Use service connections**: For Azure authentication
- **Store secrets in Azure Key Vault**: Reference them in pipelines
- **Use pipeline secrets**: For sensitive variables
- **Limit variable scope**: Use stage/job-level variables
- **Enable audit logging**: Track pipeline executions

```yaml
variables:
  - group: 'prod-secrets'  # Variable group from Azure DevOps

steps:
  - task: AzureKeyVault@2
    inputs:
      azureSubscription: $(azureSubscription)
      KeyVaultName: 'kv-myapp-prod-001'
      SecretsFilter: '*'
```

#### ❌ DON'T
- **Don't commit secrets**: Use Azure Key Vault or pipeline secrets
- **Don't use plaintext passwords**: Mark as secret
- **Don't share service principals**: One per purpose
- **Don't log sensitive data**: Mask it in logs

### Template Usage

#### ✅ DO
- **Use the latest templates**: Reference `ref: main` for updates
- **Version for stability**: Use tags for production (e.g., `ref: refs/tags/v1.0.0`)
- **Pass all required parameters**: Check template documentation
- **Test template changes**: In dev before production
- **Document customizations**: Explain parameter choices

```yaml
resources:
  repositories:
    - repository: qops-hub-infra
      type: github
      name: johanpearson/qops-hub-infra
      ref: refs/tags/v1.0.0  # Use specific version for stability

steps:
  - template: templates/deploy-bicep.yml@qops-hub-infra
    parameters:
      azureSubscription: $(azureSubscription)
      resourceGroupName: $(resourceGroupName)
      templateFile: 'qops-hub-infra/bicep/main-webapp.bicep'
```

#### ❌ DON'T
- **Don't modify templates inline**: Contribute changes back
- **Don't skip parameter validation**: Provide all required params
- **Don't ignore template updates**: Keep up to date

## Deployment Practices

### Pre-Deployment

#### ✅ DO
- **Always validate**: Use `az deployment group validate`
- **Run what-if analysis**: Preview changes before deploying
- **Test in dev first**: Never test in production
- **Review changes**: Understand what will be deployed
- **Check dependencies**: Ensure all prerequisites exist

```bash
# Validate
az deployment group validate \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/dev.parameters.json

# What-if
az deployment group what-if \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/dev.parameters.json
```

#### ❌ DON'T
- **Don't skip validation**: Always validate first
- **Don't deploy without review**: Check what-if output
- **Don't assume it works**: Test in lower environments first

### During Deployment

#### ✅ DO
- **Use descriptive deployment names**: Include timestamp or build ID
- **Monitor progress**: Watch the deployment in portal or CLI
- **Capture outputs**: Save deployment outputs
- **Handle errors gracefully**: Review and address failures
- **Keep deployments small**: Incremental changes are safer

```bash
az deployment group create \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep \
  --parameters bicep/environments/dev.parameters.json \
  --name deployment-$(date +%Y%m%d-%H%M%S)
```

#### ❌ DON'T
- **Don't use complete mode**: Use incremental (default) mode
- **Don't ignore warnings**: Address them before proceeding
- **Don't deploy too much at once**: Break into smaller deployments

### Post-Deployment

#### ✅ DO
- **Verify deployment**: Check resources were created correctly
- **Test functionality**: Ensure application works
- **Check monitoring**: Verify Application Insights is receiving data
- **Document changes**: Update documentation if needed
- **Review costs**: Check resource costs are as expected

```bash
# Verify resources
az resource list --resource-group rg-myapp-dev-weu-001 --output table

# Test app
curl https://app-myapp-dev-weu-001.azurewebsites.net/health

# Check Application Insights
az monitor app-insights component show \
  --app appi-myapp-dev-weu-001 \
  --resource-group rg-myapp-dev-weu-001
```

#### ❌ DON'T
- **Don't assume success**: Always verify
- **Don't skip smoke tests**: Test critical functionality
- **Don't ignore monitoring gaps**: Ensure telemetry flows

## Environment Management

### Environment Separation

#### ✅ DO
- **Use separate resource groups**: One per environment
- **Use separate subscriptions**: If budget allows (for prod)
- **Apply different SKUs**: Match environment needs
- **Configure appropriate backups**: More critical in prod
- **Set correct retention**: Longer for production

#### ❌ DON'T
- **Don't share resource groups**: Keep environments isolated
- **Don't use prod SKUs in dev**: Wasteful spending
- **Don't skip backups in prod**: Critical for recovery

### Cost Management

#### ✅ DO
- **Right-size resources**: Use appropriate SKUs
- **Auto-shutdown dev/test**: Save costs during off-hours
- **Monitor spending**: Set up cost alerts
- **Use tags for allocation**: Track costs by team/project
- **Clean up unused resources**: Delete when not needed

```bash
# Set up cost alert
az consumption budget create \
  --resource-group rg-myapp-dev-weu-001 \
  --name monthly-budget \
  --amount 100 \
  --time-grain Monthly \
  --category Cost
```

#### ❌ DON'T
- **Don't over-provision**: Start small, scale as needed
- **Don't leave test resources running**: Delete after use
- **Don't ignore cost alerts**: Review and adjust

## Monitoring and Observability

### Application Insights

#### ✅ DO
- **Enable for all environments**: Including dev
- **Set appropriate retention**: Based on compliance needs
- **Create alerts**: For critical metrics
- **Use custom metrics**: Track business KPIs
- **Enable distributed tracing**: For microservices

```bicep
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
    RetentionInDays: 90
  }
}
```

#### ❌ DON'T
- **Don't disable instrumentation**: Always keep it on
- **Don't ignore performance issues**: Monitor and optimize
- **Don't forget availability tests**: Set up synthetic monitoring

### Log Analytics

#### ✅ DO
- **Centralize logs**: Use one workspace per environment or across
- **Set appropriate retention**: Balance cost and compliance
- **Create dashboards**: Visualize key metrics
- **Use queries**: Kusto queries for analysis
- **Enable diagnostic settings**: For all resources

#### ❌ DON'T
- **Don't ignore logs**: Review regularly
- **Don't over-retain**: Costs increase with time
- **Don't collect everything**: Be selective about log levels

## Version Control

### Git Workflow

#### ✅ DO
- **Use feature branches**: For all changes
- **Write descriptive commits**: Clear commit messages
- **Review before merging**: Use pull requests
- **Tag releases**: Version stable releases
- **Keep history clean**: Squash when appropriate

```bash
# Create feature branch
git checkout -b feature/add-sql-module

# Make changes
git add bicep/modules/sql-database.bicep
git commit -m "Add SQL Database module with backup configuration"

# Push and create PR
git push origin feature/add-sql-module
```

#### ❌ DON'T
- **Don't commit to main**: Use branches
- **Don't commit secrets**: Use .gitignore
- **Don't skip reviews**: Always have peer review
- **Don't force push**: Especially to main

## Testing

### Infrastructure Testing

#### ✅ DO
- **Validate Bicep syntax**: Use `az bicep build`
- **Use what-if**: Preview changes
- **Test in dev first**: Validate in lower environments
- **Automate tests**: In CI/CD pipeline
- **Check for drift**: Regularly compare actual vs. desired state

```bash
# Validate syntax
az bicep build --file main.bicep

# Preview changes
az deployment group what-if \
  --resource-group rg-myapp-dev-weu-001 \
  --template-file bicep/main-webapp.bicep
```

#### ❌ DON'T
- **Don't skip testing**: Always test changes
- **Don't test only in production**: Use dev/test environments
- **Don't ignore validation errors**: Fix them

### Application Testing

#### ✅ DO
- **Run unit tests**: In build stage
- **Run integration tests**: In test environment
- **Perform smoke tests**: After deployment
- **Test rollback procedures**: Ensure you can revert
- **Load test**: Before production release

#### ❌ DON'T
- **Don't skip tests**: Failing tests should block deployment
- **Don't test only happy paths**: Test error conditions
- **Don't deploy without verification**: Always verify success

## Documentation

### Code Documentation

#### ✅ DO
- **Document parameters**: Use `@description` in Bicep
- **Add README files**: For modules and templates
- **Include examples**: Show how to use templates
- **Keep docs updated**: Update with code changes
- **Document decisions**: Why certain approaches were chosen

#### ❌ DON'T
- **Don't skip documentation**: It's crucial for teams
- **Don't assume clarity**: Explain complex logic
- **Don't leave TODOs**: Complete or remove them

## Conclusion

Following these best practices will help you:
- Deploy infrastructure safely and consistently
- Maintain security and compliance
- Reduce costs and improve efficiency
- Enable team collaboration
- Support troubleshooting and debugging

Remember: **Automate everything, test thoroughly, document clearly, and iterate continuously.**
