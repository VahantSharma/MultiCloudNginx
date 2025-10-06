# TLS Private Key and Self-Signed Certificate
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = "nginx.example.com"
    organization = "Example Corp"
  }

  validity_period_hours = 8760  # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Azure Application Gateway
resource "azurerm_application_gateway" "this" {
  name                = "nginx-appgw"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.public_subnet_ids[0]  # Assuming first public subnet
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  ssl_certificate {
    name     = "nginx-ssl-cert"
    data     = tls_self_signed_cert.example.cert_pem
    password = ""
  }

  backend_address_pool {
    name         = "nginx-backend-pool"
    ip_addresses = var.target_private_ips
  }

  backend_http_settings {
    name                  = "nginx-https-settings"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    name                           = "nginx-http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "nginx-https-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "nginx-ssl-cert"
  }

  request_routing_rule {
    name                       = "nginx-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "nginx-http-listener"
    backend_address_pool_name  = "nginx-backend-pool"
    backend_http_settings_name = "nginx-https-settings"
    priority                   = 100
  }

  request_routing_rule {
    name                       = "nginx-https-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "nginx-https-listener"
    backend_address_pool_name  = "nginx-backend-pool"
    backend_http_settings_name = "nginx-https-settings"
    priority                   = 101
  }

  probe {
    name                = "nginx-health-probe"
    host                = var.target_private_ips[0]
    interval            = 30
    path                = "/"
    port                = 443
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
  }

  tags = var.tags
}

resource "azurerm_public_ip" "appgw" {
  name                = "nginx-appgw-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}