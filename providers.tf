terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

   backend "azurerm" {
     resource_group_name  = "terraform-state-vs"
     storage_account_name = "terraformersprime"
     container_name       = "tfstate"
     key                  = "terraform.tfstate"
   }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}