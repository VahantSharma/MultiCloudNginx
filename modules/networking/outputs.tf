# Networking Module Outputs

output "azure_vnet_id" {
  description = "ID of the Azure Virtual Network"
  value       = azurerm_virtual_network.this.id
}

output "azure_public_subnet_ids" {
  description = "IDs of the Azure public subnets"
  value       = azurerm_subnet.public[*].id
}

output "azure_private_subnet_ids" {
  description = "IDs of the Azure private subnets"
  value       = azurerm_subnet.private[*].id
}