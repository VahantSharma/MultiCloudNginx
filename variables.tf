variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for Azure"
  type        = string
  default     = "Standard_B1s"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "nginx-rg"
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = "East US"
}

variable "admin_ssh_key" {
  description = "Admin SSH public key for VMs"
  type        = string
  default     = ""
}

variable "ssl_certificate_data" {
  description = "SSL certificate data (base64 PFX)"
  type        = string
  default     = ""
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = ""
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  default     = ""
}

variable "allowed_ips" {
  description = "List of allowed IP addresses or CIDRs for inbound traffic"
  type        = list(string)
  default     = ["*"]
}

variable "ssl_certificate_password" {
  description = "SSL certificate password"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}