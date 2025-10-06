# Compute Module Variables
# This file defines the inputs for the compute module

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for Azure"
  type        = string
  default     = "Standard_B1s"
}

variable "os_image" {
  description = "OS image details"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs to place instances in"
  type        = list(string)
}

variable "admin_username" {
  description = "Admin username for Azure VM"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_key" {
  description = "Admin SSH public key for Azure VM"
  type        = string
  default     = ""
}

variable "custom_data" {
  description = "Custom data script for Azure"
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "Resource group name for Azure"
  type        = string
  default     = ""
}

variable "allowed_ips" {
  description = "List of allowed IP addresses or CIDRs for inbound traffic"
  type        = list(string)
  default     = ["*"]
}

variable "location" {
  description = "Location for Azure resources"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}