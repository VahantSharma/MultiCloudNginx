# Networking Module Variables

variable "vpc_cidr" {
  description = "CIDR block for Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "resource_group_name" {
  description = "Resource group name for Azure"
  type        = string
  default     = ""
}

variable "location" {
  description = "Location for Azure"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}