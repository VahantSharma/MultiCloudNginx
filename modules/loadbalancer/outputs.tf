# Load Balancer Module Outputs

output "azure_appgw_public_ip" {
  description = "Public IP of the Azure Application Gateway"
  value       = azurerm_public_ip.appgw.ip_address
}