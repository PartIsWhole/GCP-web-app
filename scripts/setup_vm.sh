#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- Starting System Setup ---"

# 1. Update and Upgrade System
echo "--- Updating System Packages ---"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get upgrade -y

# 2. Install Common Utilities
echo "--- Installing Common Utilities (git, curl, build-essential) ---"
sudo apt-get install -y curl git unzip build-essential software-properties-common

# 3. Install Python 3, pip, and venv (for FastAPI)
echo "--- Installing Python Dependencies ---"
sudo apt-get install -y python3 python3-pip python3-venv python3-dev

# 4. Install Node.js 20.x (LTS) and npm (for React)
echo "--- Installing Node.js and npm ---"
# Check if node is already installed to avoid re-adding the repo unnecessarily
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "Node.js is already installed."
fi

# 5. Install PostgreSQL
echo "--- Installing PostgreSQL ---"
sudo apt-get install -y postgresql postgresql-contrib libpq-dev

# 6. Install Nginx (Web Server / Reverse Proxy)
echo "--- Installing Nginx ---"
sudo apt-get install -y nginx

# 7. Install Supervisor (Process Control System for FastAPI)
echo "--- Installing Supervisor ---"
sudo apt-get install -y supervisor

# 8. Firewall Setup (UFW) - Optional but recommended
# Note: GCP has its own firewall, but UFW adds a layer of security on the VM itself.
echo "--- Configuring Firewall ---"
if command -v ufw &> /dev/null; then
    sudo ufw allow OpenSSH
    sudo ufw allow 'Nginx Full'
    # Enable ufw non-interactively
    echo "y" | sudo ufw enable
fi

echo "--- Setup Complete! ---"
echo "Node Version: $(node -v)"
echo "Python Version: $(python3 --version)"