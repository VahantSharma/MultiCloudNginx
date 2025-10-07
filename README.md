# Terraform Infrastructure for Scalable NGINX Deployment on Azure

This repository contains Terraform code to provision scalable Azure infrastructure for deploying NGINX applications with Docker support.

## Overview

The infrastructure supports:

- Multiple environments (dev, staging, prod)
- Azure deployment with VMs, Virtual Networks, and Application Gateway
- Modular architecture with reusable Terraform modules
- Load balancing with HTTPS
- Remote state management with locking
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

## Deployment Steps

### 1. Set Up Azure Resources
1. Log in: `az login`
2. Create SP: `az ad sp create-for-rbac --name nginx-sp --role Contributor --scopes /subscriptions/YOUR_SUB_ID`
3. Create state storage: `az group create --name terraform-state-vs --location eastus` then storage account/container.

### 2. Configure Jenkins
- Run Jenkins in Docker: `docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home --name jenkins jenkins/jenkins:lts`
- Add Azure credentials in Jenkins (ARM_CLIENT_ID, etc.).
- Create pipeline job pointing to this repo's Jenkinsfile.

### 3. Deploy via Jenkins
- Select environment and action (plan/apply).
- Monitor for successful provisioning of VMs, App Gateway with HTTPS.

### 4. Access Application
- Get App Gateway DNS from Terraform output.
- Visit `https://<dns>` for NGINX over HTTPS.

## Security
- Use SP for auth, store secrets in Jenkins.
- NSG restricts IPs in prod.
- Self-signed certs (replace with CA-signed for prod).
