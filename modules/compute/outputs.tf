# Compute Module Outputs

output "azure_vm_ids" {
  description = "IDs of the Azure VMs"
  value       = azurerm_linux_virtual_machine.this[*].id
}

output "azure_private_ips" {
  description = "Private IPs of the Azure VMs"
  value       = azurerm_network_interface.this[*].private_ip_address
}