# Networking Module Main Configuration

# Azure Virtual Network
resource "azurerm_virtual_network" "this" {
  name                = "nginx-vnet"
  address_space       = [var.vpc_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Azure Public Subnet
resource "azurerm_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  name                 = "nginx-public-subnet-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.public_subnet_cidrs[count.index]]
}

# Azure Private Subnet
resource "azurerm_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  name                 = "nginx-private-subnet-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.private_subnet_cidrs[count.index]]
}

# Azure NAT Gateway for outbound internet access
resource "azurerm_nat_gateway" "this" {
  name                    = "nginx-nat-gw"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

# Azure NAT Gateway Association with Private Subnet
resource "azurerm_subnet_nat_gateway_association" "this" {
  count = length(azurerm_subnet.private)

  subnet_id      = azurerm_subnet.private[count.index].id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

# Azure Public IP for NAT Gateway
resource "azurerm_public_ip" "nat" {
  name                = "nginx-nat-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Associate Public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat.id
}