#!/bin/bash

# Update package repositories
echo "Updating package repositories..."
apt-get update

# Install Fish shell
echo "Installing Fish shell..."
apt-get install -y fish curl

# Install Starship
echo "Installing Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Set Fish as default shell
echo "Setting Fish as default shell..."
chsh -s $(which fish)

# Create Fish config directory if it doesn't exist
mkdir -p ~/.config/fish

# Configure Starship for Fish
echo "Configuring Starship..."
echo 'starship init fish | source' > ~/.config/fish/config.fish

echo "Installation complete! Please log out and log back in for changes to take effect."
