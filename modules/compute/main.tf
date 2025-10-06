# Compute Module Main Configuration
# This module creates compute instances (VMs) on Azure

# Azure Network Security Group
resource "azurerm_network_security_group" "this" {
  name                = "nginx-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_ips
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = var.allowed_ips
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.allowed_ips
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Azure Linux Virtual Machines
resource "azurerm_linux_virtual_machine" "this" {
  count = var.instance_count

  name                = "nginx-vm-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.this[count.index].id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.os_image.publisher
    offer     = var.os_image.offer
    sku       = var.os_image.sku
    version   = var.os_image.version
  }

  custom_data = base64encode(var.custom_data)

  tags = var.tags
}

# Azure Network Interface
resource "azurerm_network_interface" "this" {
  count = var.instance_count

  name                = "nic-nginx-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = element(var.subnet_ids, count.index % length(var.subnet_ids))
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "this" {
  count = var.instance_count

  network_interface_id      = azurerm_network_interface.this[count.index].id
  network_security_group_id = azurerm_network_security_group.this.id
}

# Outputs
output "private_ips" {
  description = "Private IP addresses of the VMs"
  value       = azurerm_network_interface.this[*].private_ip_address
}