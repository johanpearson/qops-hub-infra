# Architecture Overview

## System Architecture

The qops-hub-infra repository provides a centralized, standardized approach to infrastructure management and deployment automation across all qops microservices.

## Design Principles

### 1. **Modularity**
- Reusable Bicep modules for common Azure resources
- Template-based pipeline components
- Composable infrastructure building blocks

### 2. **Consistency**
- Standardized naming conventions following Microsoft CAF
- Uniform tagging strategy across all resources
- Common deployment patterns

### 3. **Security First**
- HTTPS-only enforcement
- Minimum TLS 1.2
- Managed identities for Azure resources
- Azure RBAC for access control
- Key Vault integration for secrets
- No hardcoded credentials

### 4. **Environment Isolation**
- Separate resource groups per environment
- Environment-specific parameter files
- Independent deployments per environment

### 5. **Observability**
- Application Insights for application monitoring
- Log Analytics for centralized logging
- Automated instrumentation

## Infrastructure Components

### Compute Resources

#### App Service Plan
- Hosts web applications and APIs
- Supports both Linux and Windows
- Configurable SKUs based on environment
- Scalable compute tier

#### App Service (Web Apps)
- Managed platform for web applications
- Built-in CI/CD integration
- Auto-scaling capabilities
- Custom domain and SSL support
- Deployment slots for zero-downtime updates

### Storage Resources

#### Storage Account
- Blob storage for application data
- Multiple redundancy options (LRS, GRS, ZRS)
- Lifecycle management policies
- Soft delete protection

#### Key Vault
- Centralized secrets management
- Certificate storage
- Encryption key management
- Access audit logging

### Container Resources

#### Container Registry
- Private Docker image repository
- Geo-replication support
- Webhook integration for automation
- Vulnerability scanning (Premium tier)

### Monitoring Resources

#### Log Analytics Workspace
- Centralized log aggregation
- Query and analysis capabilities
- Long-term log retention
- Integration with Azure Monitor

#### Application Insights
- Application performance monitoring
- Distributed tracing
- Custom telemetry
- Real-time metrics
- Availability monitoring

## Network Architecture

### Basic Network Design

```
┌─────────────────────────────────────────────────────────┐
│                    Azure Subscription                    │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │          Resource Group (per environment)          │ │
│  │                                                     │ │
│  │  ┌──────────────────────────────────────────────┐ │ │
│  │  │         Azure Front Door (Optional)          │ │ │
│  │  └──────────────────────────────────────────────┘ │ │
│  │                        │                           │ │
│  │                        ▼                           │ │
│  │  ┌──────────────────────────────────────────────┐ │ │
│  │  │            App Service Plan                  │ │ │
│  │  │  ┌────────────┐  ┌────────────┐             │ │ │
│  │  │  │ App Svc 1  │  │ App Svc 2  │    ...      │ │ │
│  │  │  └────────────┘  └────────────┘             │ │ │
│  │  └──────────────────────────────────────────────┘ │ │
│  │                        │                           │ │
│  │         ┌──────────────┼──────────────┐           │ │
│  │         ▼              ▼              ▼           │ │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐   │ │
│  │  │ Storage   │  │ Key Vault │  │    SQL    │   │ │
│  │  │ Account   │  │           │  │ Database  │   │ │
│  │  └───────────┘  └───────────┘  └───────────┘   │ │
│  │                                                   │ │
│  │  ┌───────────────────────────────────────────┐  │ │
│  │  │     Application Insights                  │  │ │
│  │  │     (backed by Log Analytics)             │  │ │
│  │  └───────────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

## Deployment Architecture

### Multi-Stage Pipeline Flow

```
┌──────────────┐
│   Source     │
│   Control    │  (GitHub)
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────┐
│          Azure DevOps Pipeline           │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │   Stage 1: Build                   │ │
│  │   • Compile code                   │ │
│  │   • Run tests                      │ │
│  │   • Create artifacts               │ │
│  └────────────────────────────────────┘ │
│                   │                      │
│                   ▼                      │
│  ┌────────────────────────────────────┐ │
│  │   Stage 2: Deploy Dev              │ │
│  │   • Deploy infrastructure          │ │
│  │   • Deploy application             │ │
│  │   • Run smoke tests                │ │
│  └────────────────────────────────────┘ │
│                   │                      │
│                   ▼                      │
│  ┌────────────────────────────────────┐ │
│  │   Stage 3: Deploy Test             │ │
│  │   • Deploy infrastructure          │ │
│  │   • Deploy application             │ │
│  │   • Run integration tests          │ │
│  └────────────────────────────────────┘ │
│                   │                      │
│                   ▼                      │
│  ┌────────────────────────────────────┐ │
│  │   Stage 4: Deploy Prod             │ │
│  │   • Manual approval                │ │
│  │   • Deploy infrastructure          │ │
│  │   • Deploy to staging slot         │ │
│  │   • Swap slots                     │ │
│  └────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

## Environment Strategy

### Development (dev)
- **Purpose**: Active development and testing
- **SKU**: Basic tier resources
- **Backup**: Disabled
- **Auto-scaling**: Disabled
- **Access**: Development team

### Test (test)
- **Purpose**: Integration and QA testing
- **SKU**: Basic tier resources
- **Backup**: Disabled
- **Auto-scaling**: Disabled
- **Access**: Development and QA teams

### Staging (staging)
- **Purpose**: Pre-production validation
- **SKU**: Standard tier resources
- **Backup**: Enabled
- **Auto-scaling**: Optional
- **Access**: Limited access

### Production (prod)
- **Purpose**: Live production workloads
- **SKU**: Premium tier resources
- **Backup**: Enabled with retention
- **Auto-scaling**: Enabled
- **Access**: Restricted access

## Security Architecture

### Identity and Access

```
┌──────────────────────────────────────────────────┐
│         Azure Active Directory (Entra ID)        │
│                                                  │
│  ┌────────────────┐      ┌──────────────────┐  │
│  │  Service       │      │  Managed         │  │
│  │  Principals    │      │  Identities      │  │
│  └────────────────┘      └──────────────────┘  │
│         │                        │              │
└─────────┼────────────────────────┼──────────────┘
          │                        │
          ▼                        ▼
┌─────────────────────────────────────────────────┐
│           Azure RBAC Assignments                │
│                                                 │
│  • Contributor: CI/CD Pipeline                  │
│  • Key Vault Secrets User: Applications         │
│  • Reader: Monitoring Services                  │
└─────────────────────────────────────────────────┘
```

### Secret Management

1. **No Secrets in Code**: All sensitive data in Key Vault
2. **Managed Identities**: Applications use MSI to access Key Vault
3. **RBAC Authorization**: Fine-grained access control
4. **Audit Logging**: All access is logged and monitored

## Monitoring and Observability

### Monitoring Stack

```
Application Code
      │
      ├──> Application Insights SDK
      │         │
      │         ├──> Exceptions
      │         ├──> Traces
      │         ├──> Metrics
      │         └──> Dependencies
      │
      ▼
Log Analytics Workspace
      │
      ├──> Queries & Analysis
      ├──> Dashboards
      ├──> Alerts & Notifications
      └──> Long-term Storage
```

### Key Metrics Monitored

- **Performance**: Response times, throughput, resource utilization
- **Availability**: Uptime, health checks, synthetic transactions
- **Errors**: Exception rates, failed requests, error distribution
- **Dependencies**: External service calls, database queries
- **Custom**: Business-specific metrics and KPIs

## Scalability Considerations

### Horizontal Scaling
- App Service instances can scale out automatically
- Multiple instances behind load balancer
- Session affinity disabled (stateless applications)

### Vertical Scaling
- SKU upgrades for increased capacity
- Environment-based SKU configuration
- Seamless during deployment

### Data Tier Scaling
- Storage accounts: Automatic scaling
- Databases: Configurable DTUs/vCores
- Caching: Redis for performance

## Disaster Recovery

### Backup Strategy
- **Databases**: Automated backups with point-in-time restore
- **Storage**: Geo-redundant replication (production)
- **Code**: Version control (Git)
- **Infrastructure**: Infrastructure as Code (Bicep)

### Recovery Objectives
- **Dev/Test**: Best effort, no formal SLA
- **Staging**: RTO 4h, RPO 1h
- **Production**: RTO 1h, RPO 15min

## Cost Optimization

### Strategies
1. **Right-sizing**: Environment-appropriate SKUs
2. **Auto-scaling**: Scale down during off-hours (dev/test)
3. **Reserved Instances**: Commitment pricing for production
4. **Resource Cleanup**: Automatic deletion of test resources
5. **Tagging**: Cost center allocation and tracking

## Compliance and Governance

### Resource Tagging
- Environment classification
- Cost center allocation
- Owner identification
- Compliance requirements

### Policy Enforcement
- Naming conventions validation
- Required tags enforcement
- Allowed resource types
- Region restrictions

## Future Enhancements

### Short-term
- [ ] Azure Container Apps support
- [ ] API Management integration
- [ ] Service Bus modules
- [ ] SQL Database modules

### Medium-term
- [ ] Multi-region deployment support
- [ ] Advanced networking (VNet integration)
- [ ] Azure Kubernetes Service (AKS) templates
- [ ] Cosmos DB modules

### Long-term
- [ ] GitOps workflow integration
- [ ] Policy-as-Code implementation
- [ ] Advanced monitoring dashboards
- [ ] Automated cost optimization

## Conclusion

This architecture provides a solid foundation for scalable, secure, and maintainable cloud infrastructure. It balances flexibility with standardization, enabling teams to move quickly while maintaining consistency and best practices across all environments.
