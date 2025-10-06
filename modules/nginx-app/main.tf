# This module generates the deployment script for NGINX with Docker and SSL

locals {
  dockerfile = <<EOF
FROM nginx:alpine

# Install OpenSSL
RUN apk add --no-cache openssl

# Create certs directory
RUN mkdir -p /etc/nginx/certs

# Generate self-signed certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/certs/key.pem \
  -out /etc/nginx/certs/cert.pem \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=nginx.example.com"

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
EOF

  nginx_conf = <<EOF
events {
  worker_connections 1024;
}

http {
  server {
    listen 443 ssl;
    server_name nginx.example.com;
    ssl_certificate /etc/nginx/certs/cert.pem;
    ssl_certificate_key /etc/nginx/certs/key.pem;
    location / {
      return 200 "Hello from NGINX over HTTPS!";
      add_header Content-Type text/plain;
    }
  }
  server {
    listen 80;
    server_name nginx.example.com;
    return 301 https://$server_name$request_uri;
  }
}
EOF

  user_data_script = <<EOF
#!/bin/bash
# Update system
apt-get update -y
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Create Dockerfile
cat > /home/ubuntu/Dockerfile << 'DOCKERFILE'
${local.dockerfile}
DOCKERFILE

# Create nginx.conf
cat > /home/ubuntu/nginx.conf << 'NGINXCONF'
${local.nginx_conf}
NGINXCONF

cd /home/ubuntu
docker build -t nginx-app .
docker run -d -p 80:80 -p 443:443 nginx-app
EOF
}

# Output the user data script
output "user_data" {
  description = "User data script for deploying NGINX app"
  value       = local.user_data_script
}