# Terraform Infrastructure for Scalable NGINX Deployment on Azure

This repository contains Terraform code to provision scalable Azure infrastructure for deploying NGINX applications with Docker support.

## Overview

The infrastructure supports:

- Multiple environments (dev, staging, prod) using Terraform workspaces
- Azure deployment with VMs, Virtual Networks, and Application Gateway
- Modular architecture with reusable Terraform modules
- Load balancing with HTTPS using self-signed certificates
- Remote state management with locking in Azure Storage Account
- CI/CD integration with Jenkins

## Architecture

### Modules

- **compute**: Creates Azure VMs with Docker and NGINX
- **networking**: Sets up Virtual Network, subnets, NAT Gateway
- **loadbalancer**: Deploys Azure Application Gateway with SSL
- **nginx-app**: Generates Docker setup scripts with OpenSSL certs

### Environments

- **dev**: Single instance in nginx-dev-rg
- **staging**: Single instance in nginx-staging-rg
- **prod**: Multi-instance in nginx-prod-rg

## Prerequisites

- Terraform >= 1.5
- Azure CLI configured
- Docker
- Jenkins (for CI/CD)
- Azure Subscription with Contributor permissions

## Setup Steps

### 1. Set Up Azure Resources

1. Log in to Azure CLI:
   ```bash
   az login
   ```

2. Create a Resource Group for Terraform state:
   ```bash
   az group create --name terraform-state-vs --location eastus
   ```

3. Create a Storage Account:
   ```bash
   az storage account create --name terraformersprime --resource-group terraform-state-vs --location eastus --sku Standard_LRS
   ```

4. Create a Storage Container:
   ```bash
   az storage container create --name tfstate --account-name terraformersprime
   ```

5. Create a Service Principal with Contributor role:
   ```bash
   az ad sp create-for-rbac --name nginx-sp --role Contributor --scopes /subscriptions/YOUR_SUBSCRIPTION_ID
   ```
   Note the `appId`, `password`, `tenant`.

### 2. Configure Jenkins

1. Run Jenkins in Docker:
   ```bash
   docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home --name jenkins jenkins/jenkins:lts
   ```

2. Access Jenkins at `http://localhost:8080` and complete setup.

3. Install necessary plugins: Terraform, Azure Credentials.

4. Add Azure credentials in Jenkins:
   - Go to Manage Jenkins > Manage Credentials > System > Global credentials
   - Add credentials for:
     - `azure-client-id`: The appId from SP
     - `azure-client-secret`: The password from SP
     - `azure-subscription-id`: Your subscription ID
     - `azure-tenant-id`: The tenant from SP

5. Create a new Pipeline job:
   - Name: nginx-deployment
   - Pipeline: Pipeline script from SCM
   - SCM: Git
   - Repository URL: https://github.com/VahantSharma/MultiCloudNginx.git
   - Script Path: Jenkinsfile

### 3. Prepare Terraform Variables

Copy the example tfvars files and update with your values:
```bash
cp dev.tfvars.example dev.tfvars
cp staging.tfvars.example staging.tfvars
cp prod.tfvars.example prod.tfvars
```

Edit the `.tfvars` files (these are gitignored):
- Replace `REPLACE_WITH_YOUR_SUBSCRIPTION_ID` with your Azure Subscription ID
- Replace `REPLACE_WITH_YOUR_TENANT_ID` with your Tenant ID
- Replace `REPLACE_WITH_YOUR_SSH_PUBLIC_KEY` with your SSH public key

For prod, ensure `instance_count = 2` for scalability.

### 4. Initialize Terraform Backend

For local testing, initialize with backend config:
```bash
terraform init -backend-config="resource_group_name=terraform-state-vs" -backend-config="storage_account_name=terraformersprime" -backend-config="container_name=tfstate" -backend-config="key=terraform-dev.tfstate"
```

### 5. Local Testing (Optional)

```bash
terraform workspace select dev  # or 'terraform workspace new dev'
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

### 4. Deploy via Jenkins

1. In Jenkins, select the pipeline job.
2. Click "Build with Parameters".
3. Choose ENVIRONMENT (dev, staging, prod) and ACTION (plan, apply, destroy).
4. Click Build.

The pipeline will:
- Initialize Terraform
- Select/Create the workspace for the environment
- Plan or Apply the infrastructure
- For apply, provision VMs, network, load balancer with HTTPS

### 5. Access the Application

After deployment:
1. Get the Application Gateway public IP from Terraform outputs or Azure portal.
2. Visit `https://<app-gateway-ip>` (accept self-signed cert warning).
3. The NGINX app should respond with "Hello from NGINX over HTTPS!" on HTTPS, and redirect HTTP to HTTPS.

### 6. Scaling

To scale compute:
- Update `instance_count` in the respective `.tfvars` file.
- Run the Jenkins pipeline with apply for that environment.

The load balancer will automatically distribute traffic to all instances.

## Security Notes

- Use Service Principal for authentication, store secrets securely in Jenkins.
- NSG allows SSH and HTTP/HTTPS; restrict `allowed_ips` in prod.
- Self-signed certificates are used; replace with CA-signed for production.
- VMs have no public IPs; access via bastion or VPN if needed.

## Troubleshooting

- If Terraform init fails, ensure Azure credentials are correct.
- If VM deployment fails, check SSH key and admin username.
- If HTTPS doesn't work, verify certificates and ports.

## Optional: Global DNS Routing

To add DNS failover:
1. Create a Route 53 hosted zone or use Azure DNS.
2. Point `nginx.example.com` to the Application Gateway IP.
3. For multi-region, add another deployment and use latency-based routing.
