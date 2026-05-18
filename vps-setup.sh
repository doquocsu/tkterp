#!/bin/bash

# TKTErp - VPS Provisioning Script for AlmaLinux
# This script handles the initial setup required to run Odoo 19 with Podman.

set -e

echo "--- Starting VPS Provisioning for TKTErp ---"

# 1. Update and Install Podman
echo "Installing Podman..."
sudo dnf update -y
sudo dnf install -y podman git

# 2. Enable Linger for the current user
# This allows rootless containers to run even when the user is logged out.
echo "Enabling linger for $USER..."
sudo loginctl enable-linger $USER

# 3. Configure Firewall
# Odoo default port is 8069.
echo "Configuring firewall for port 8069..."
sudo firewall-cmd --permanent --add-port=8069/tcp
sudo firewall-cmd --reload

# 4. Create Project Structure
echo "Creating project directories..."
mkdir -p ~/projects/tkterp/tkterp-addons
mkdir -p ~/projects/tkterp/tkterp-db-data
mkdir -p ~/projects/tkterp/tkterp-data
mkdir -p ~/projects/tkterp/nginx/html
mkdir -p ~/projects/tkterp/nginx/maintenance

# Set permissions
chmod -R 777 ~/projects/tkterp/tkterp-db-data
chmod -R 777 ~/projects/tkterp/tkterp-data
chmod -R 777 ~/projects/tkterp/tkterp-addons
chmod -R 777 ~/projects/tkterp/nginx/maintenance

# 5. Setup systemd directory
echo "Creating systemd Quadlet directory..."
mkdir -p ~/.config/containers/systemd

echo "--- Provisioning Complete! ---"
echo "Next steps:"
echo "1. Add your SSH Public Key to ~/.ssh/authorized_keys"
echo "2. Configure GitHub Secrets (VPS_HOST, SSH_PRIVATE_KEY, etc.)"
echo "3. Push your code to the 'main' branch to trigger the first deployment."
