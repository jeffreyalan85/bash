#!/bin/bash

# Exit on any error
set -e

echo "Starting secure Docker installation..."

# Remove any old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install prerequisites
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create docker daemon configuration with secure defaults
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
    "live-restore": true,
    "no-new-privileges": true,
    "userns-remap": "default",
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    }
}
EOF

# Restart Docker daemon
sudo systemctl restart docker

# Install Portainer
sudo docker volume create portainer_data
sudo docker run -d \
    --name portainer \
    --restart=always \
    -p 9443:9443 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest \
    --ssl

# Add current user to docker group (requires logout/login to take effect)
sudo usermod -aG docker $USER

# Set proper permissions
sudo chmod 660 /var/run/docker.sock

echo "Installation complete! Please log out and log back in for group changes to take effect."
echo "Portainer is available at: https://localhost:9443"
echo "Please change the default admin password on first login to Portainer"
