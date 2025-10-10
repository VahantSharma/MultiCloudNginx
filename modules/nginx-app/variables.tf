# NGINX App Module Variables

variable "nginx_port" {
  description = "Port for NGINX to listen on"
  type        = number
  default     = 443
}

variable "ssl_cert_path" {
  description = "Path to SSL certificate"
  type        = string
  default     = "/etc/nginx/certs/cert.pem"
}

variable "ssl_key_path" {
  description = "Path to SSL private key"
  type        = string
  default     = "/etc/nginx/certs/key.pem"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}