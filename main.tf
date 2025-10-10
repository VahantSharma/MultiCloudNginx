# Resource Group
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Wait for RG to be fully ready
resource "time_sleep" "wait_for_rg" {
  depends_on      = [azurerm_resource_group.this]
  create_duration = "30s"
}

# Networking Module
module "networking" {
  source     = "./modules/networking"
  depends_on = [time_sleep.wait_for_rg]

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  resource_group_name  = var.resource_group_name
  location             = var.location
  tags                 = merge(var.tags, { Environment = var.environment })
}

# NGINX App Module
module "nginx_app" {
  source = "./modules/nginx-app"

  admin_username = var.admin_username
}

# Compute Module
module "compute" {
  source     = "./modules/compute"
  depends_on = [time_sleep.wait_for_rg]

  instance_count      = var.instance_count
  vm_size             = var.vm_size
  subnet_ids          = module.networking.azure_private_subnet_ids
  resource_group_name = var.resource_group_name
  location            = var.location
  custom_data         = module.nginx_app.user_data
  admin_ssh_key       = var.admin_ssh_key
  allowed_ips         = var.allowed_ips
  tags                = merge(var.tags, { Environment = var.environment })
}

# Load Balancer Module
module "loadbalancer" {
  source     = "./modules/loadbalancer"
  depends_on = [time_sleep.wait_for_rg]

  resource_group_name = var.resource_group_name
  location            = var.location
  public_subnet_ids   = module.networking.azure_public_subnet_ids
  target_private_ips  = module.compute.private_ips
  tags                = merge(var.tags, { Environment = var.environment })
}

# Outputs
output "app_gateway_public_ip" {
  description = "Public IP of the Azure Application Gateway"
  value       = module.loadbalancer.azure_appgw_public_ip
}

output "vm_private_ips" {
  description = "Private IPs of the VMs"
  value       = module.compute.private_ips
}