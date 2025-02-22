#!/bin/bash

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (with sudo)"
    exit 1
fi

# Print status function
print_status() {
    echo "===> $1"
}

# Error handling function
handle_error() {
    echo "Error: $1"
    exit 1
}

# System update and upgrade
print_status "Updating system packages"
apt-get update || handle_error "Failed to update package list"
print_status "Upgrading system packages"
apt-get upgrade -y || handle_error "Failed to upgrade packages"

# Update package list
print_status "Updating package list"
apt-get update || handle_error "Failed to update package list"

# Install dependencies
print_status "Installing dependencies"
apt-get install -y curl git build-essential || handle_error "Failed to install dependencies"

# Install Fish shell
print_status "Installing Fish shell"
apt-get install -y fish || handle_error "Failed to install Fish"

# Install Cargo (required for Zellij)
print_status "Installing Rust and Cargo"
curl https://sh.rustup.rs -sSf | sh -s -- -y || handle_error "Failed to install Rust"
source "$HOME/.cargo/env"

# Install Zellij
print_status "Installing Zellij"
cargo install zellij || handle_error "Failed to install Zellij"

# Set Fish as default shell for current user
current_user=$(logname)
print_status "Setting Fish as default shell for $current_user"
chsh -s $(which fish) "$current_user" || handle_error "Failed to set Fish as default shell"

print_status "Installation complete! Please log out and log back in for changes to take effect."
