#!/bin/bash

# Exit on error
set -e

echo "========================================"
echo "      Deploying React App to Nginx      "
echo "========================================"

# 1. Resolve Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
WEB_ROOT="/var/www/html/react-app"

echo "Project Root: $PROJECT_ROOT"
echo "Frontend Dir: $FRONTEND_DIR"

# 2. Check if frontend exists
if [ ! -d "$FRONTEND_DIR" ]; then
    echo "Error: 'frontend' directory not found."
    echo "Please run scripts/create_frontend.sh first."
    exit 1
fi

# 3. Build the React Application
echo "--- Building Frontend ---"
cd "$FRONTEND_DIR"
# Ensure dependencies are installed
if [ ! -d "node_modules" ]; then
    npm install
fi
npm run build

# 4. Deploy to Web Root (avoiding permission issues in home dir)
echo "--- Moving Build Artifacts to $WEB_ROOT ---"
sudo mkdir -p "$WEB_ROOT"
sudo rm -rf "$WEB_ROOT"/*
sudo cp -r dist/* "$WEB_ROOT/"

# 5. Configure Nginx
echo "--- Configuring Nginx ---"
# Create Nginx config file
sudo bash -c "cat > /etc/nginx/sites-available/default" <<EOF
server {
    listen 80;
    server_name _;

    root $WEB_ROOT;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# 6. Restart Nginx
echo "--- Restarting Nginx ---"
sudo systemctl restart nginx

echo "========================================"
echo "Deployment Complete!"
echo "Open your VM's External IP in a browser to view the app."
echo "========================================"