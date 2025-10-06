# Load Balancer Module Variables

variable "resource_group_name" {
  description = "Resource group for Azure"
  type        = string
  default     = ""
}

variable "location" {
  description = "Location for Azure"
  type        = string
  default     = "East US"
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "target_private_ips" {
  description = "Private IPs for backend targets"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}