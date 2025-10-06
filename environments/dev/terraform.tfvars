environment    = "dev"
instance_count = 1
vm_size        = "Standard_B1s"
vpc_cidr       = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24"]
private_subnet_cidrs = ["10.0.2.0/24"]
resource_group_name = "nginx-dev-rg"
location = "East US"
subscription_id = "REPLACE_WITH_YOUR_SUBSCRIPTION_ID"
tenant_id       = "REPLACE_WITH_YOUR_TENANT_ID"
admin_ssh_key = "REPLACE_WITH_YOUR_SSH_PUBLIC_KEY"
tags = {
  Project = "nginx-app"
  Owner   = "dev-team"
}