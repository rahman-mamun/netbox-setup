#!/bin/bash

# Step 1: Update system and install prerequisites
dnf update -y
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin git

# Step 2: Start and enable Docker
systemctl start docker
systemctl enable docker

# Step 3: Create directory and clone NetBox-Docker repository
mkdir -p /opt/netbox-docker
cd /opt/netbox-docker
git clone -b release https://github.com/netbox-community/netbox-docker.git .

# Step 4: Create Docker override file for customization
cat << 'EOF' > docker-compose.override.yml
version: '3.4'
services:
  netbox:
    ports:
      - 8000:8080
    environment:
      SUPERUSER_NAME: admin
      SUPERUSER_EMAIL: 
      SUPERUSER_PASSWORD: 68tke36eahj752am
      ALLOWED_HOSTS: '*'
EOF

# Step 5: Start NetBox containers
docker compose pull
docker compose up -d

# Step 6: Configure firewall
firewall-cmd --permanent --add-port=8000/tcp
firewall-cmd --reload

# Get server IP
SERVER_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -n 1)

# Print completion message
echo "==================================================="
echo "NetBox installation complete!"
echo "Access NetBox at: http://$SERVER_IP:8000"
echo "Default credentials:"
echo "Username: admin"
echo "Password: admin"
echo "==================================================="
