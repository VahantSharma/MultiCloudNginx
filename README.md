# Terraform Infrastructure for Scalable NGINX Deployment on Azure

This repository contains Terraform code to provision scalable Azure infrastructure for deploying NGINX applications with Docker support.

## Overview

The infrastructure supports:

- Multiple environments (dev, staging, prod)
- Azure deployment with VMs, Virtual Networks, and Application Gateway
- Modular architecture with reusable Terraform modules
- Load balancing
- Remote state management
- CI/CD integration

## Architecture

### Modules

- **compute**: Creates Azure VMs with Docker and NGINX
- **networking**: Sets up Virtual Network, subnets, NAT Gateway
- **loadbalancer**: Deploys Azure Application Gateway
- **nginx-app**: Generates Docker setup scripts

### Environments

- **dev**: Single instance in nginx-dev-rg
- **staging**: Single instance in nginx-staging-rg
- **prod**: Multi-instance in nginx-prod-rg

## Prerequisites

- Terraform >= 1.5
- Azure CLI configured
- Docker

## Deployment

### Local Deployment

1. Configure Azure CLI:

   ```bash
   az login
   ```

2. Navigate to the environment directory:

   ```bash
   cd environments/dev
   ```

3. Initialize Terraform:

   ```bash
   terraform init
   ```

4. Plan the deployment:

   ```bash
   terraform plan -var-file=terraform.tfvars
   ```

5. Apply the changes:
   ```bash
   terraform apply -var-file=terraform.tfvars
   ```

### CI/CD Deployment

#### Jenkins

- Use the provided `Jenkinsfile`
- Set environment variables for cloud credentials
- Trigger pipeline with parameters

#### Azure DevOps

- Use the provided `azure-pipelines.yml`
- Configure variable groups for secrets
- Run pipeline with parameters

## Outputs

After deployment, note the Application Gateway public IP:

- Azure App Gateway: `module.loadbalancer.azure_appgw_public_ip`

Access the application at `http://<appgw-public-ip>`.

## Security Notes

- Restrict SSH access in production

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy -var-file=terraform.tfvars
```

## Contributing

1. Follow modular structure
2. Test changes in dev environment first
3. Update documentation

## Optional: Global DNS Routing

To route traffic globally using Azure Traffic Manager:

- Create a Traffic Manager profile for `nginx.example.com`
- Add endpoints pointing to Application Gateway public IPs
- Use performance-based routing for multi-region deployments

Example Terraform:

```hcl
resource "azurerm_traffic_manager_profile" "nginx" {
  name                   = "nginx-traffic-manager"
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "nginx"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_endpoint" "nginx" {
  name                = "nginx-endpoint"
  resource_group_name = var.resource_group_name
  profile_name        = azurerm_traffic_manager_profile.nginx.name
  target_resource_id  = azurerm_public_ip.appgw.id
  type                = "azureEndpoints"
}
```
