#!/bin/bash

# ===============================
# DevOps AWS - Auto Setup Script (FINAL)
# ===============================

# === Variables ===
APP_DIR="/opt/todowebapi"
BINARY_FILE="Binary-linux-x64.7z"
DDL_FILE="TodoItem_DDL.sql"
APP_DLL="TodoWebAPI.dll"

RDS_ENDPOINT="terraform-20250429021147512700000001.c5ya80m00geq.ap-southeast-1.rds.amazonaws.com"        # default local MySQL server
DB_NAME="MyWebApiDB"
DB_USER="tempAdmin"
DB_PASS="!tempAdmin954*"

APP_PORT=5000

# === 0. Copies Code From S3 Bucket ===
echo "[*] Copies Code..."
aws s3 cp s3://my-webapp-bucket-91a19527/ ~/ --recursive

# === 1. Update & Install Dependencies ===
echo "[*] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[*] Installing required packages..."
sudo apt install -y p7zip-full nginx wget

# Install .NET Runtime
echo "[*] Installing .NET Runtime..."
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install -y aspnetcore-runtime-8.0

# === 3. Import DDL SQL ===
if [ -f "$DDL_FILE" ]; then
    echo "[*] Importing DDL file into database..."
    sudo mysql -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < "${DDL_FILE}"
else
    echo "[!] DDL file '${DDL_FILE}' not found, skipping SQL import!"
fi

# === 4. Setup Application ===
echo "[*] Setting up application folder..."
sudo mkdir -p "$APP_DIR"
sudo 7z x "$BINARY_FILE" -o"$APP_DIR"
sudo chown -R $USER:$USER "$APP_DIR"

# === 5. Setup Environment Variable for DB Connection ===
echo "[*] Exporting environment variable for DB connection..."
export ConnectionStrings__DefaultConnection="server=${RDS_ENDPOINT};userid=${DB_USER};password=${DB_PASS};database=${DB_NAME}"

# === 6. Create Systemd Service to Run App Automatically ===
echo "[*] Creating systemd service..."

SERVICE_FILE="/etc/systemd/system/todowebapi.service"

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=TodoWebAPI Service
After=network.target

[Service]
Environment="ConnectionStrings__DefaultConnection=server=${RDS_ENDPOINT};userid=${DB_USER};password=${DB_PASS};database=${DB_NAME}"
WorkingDirectory=${APP_DIR}
ExecStart=/usr/bin/dotnet ${APP_DIR}/${APP_DLL}
Restart=always
RestartSec=10
SyslogIdentifier=todowebapi
User=${USER}
Environment=ASPNETCORE_URLS=http://0.0.0.0:${APP_PORT}

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable todowebapi
sudo systemctl restart todowebapi

# === 7. Configure Nginx Reverse Proxy ===
echo "[*] Setting up Nginx reverse proxy..."

NGINX_CONF="/etc/nginx/sites-available/default"

sudo bash -c "cat > $NGINX_CONF" <<EOL
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:${APP_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

sudo systemctl restart nginx

# === DONE ===
echo ""
echo "=========================================="
echo "✅ Deployment Completed Successfully!"
echo ""
echo "🌐 Access your app at: http://[your-server-ip]/api-docs/"
echo "🔐 MySQL App User: ${DB_USER} / Password: ${DB_PASS}"
echo "📂 App Folder: ${APP_DIR}"
echo "=========================================="