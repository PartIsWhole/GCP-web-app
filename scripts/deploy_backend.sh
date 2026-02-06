#!/bin/bash

# Exit on error
set -e

echo "========================================"
echo "      Deploying FastAPI Backend         "
echo "========================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKEND_DIR="$PROJECT_ROOT/backend"
VENV_DIR="$BACKEND_DIR/venv"
USER_NAME=$(whoami)

# 1. Setup Python Virtual Environment
echo "--- Setting up Virtual Environment ---"
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi

# Install dependencies
"$VENV_DIR/bin/pip" install -r "$BACKEND_DIR/requirements.txt"

# 2. Configure Supervisor
echo "--- Configuring Supervisor ---"
SUPERVISOR_CONF="/etc/supervisor/conf.d/fastapi.conf"

# Create Supervisor config file
sudo bash -c "cat > $SUPERVISOR_CONF" <<EOF
[program:fastapi]
directory=$BACKEND_DIR
command=$VENV_DIR/bin/uvicorn main:app --host 0.0.0.0 --port 8000
user=$USER_NAME
autostart=true
autorestart=true
stderr_logfile=/var/log/fastapi.err.log
stdout_logfile=/var/log/fastapi.out.log
EOF

# Reload Supervisor to apply changes
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart fastapi

# 3. Update Nginx Configuration (Frontend + Backend Proxy)
echo "--- Updating Nginx Configuration ---"
WEB_ROOT="/var/www/html/react-app"

sudo bash -c "cat > /etc/nginx/sites-available/default" <<EOF
server {
    listen 80;
    server_name _;

    # Serve React Frontend
    root $WEB_ROOT;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Proxy API requests to FastAPI
    location /api {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# 4. Restart Nginx
echo "--- Restarting Nginx ---"
sudo systemctl restart nginx

echo "========================================"
echo "Backend Deployed & Nginx Updated!"
echo "Test it at: http://<YOUR_VM_IP>/api"
echo "========================================"