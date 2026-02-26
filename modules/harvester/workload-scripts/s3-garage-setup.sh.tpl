#!/bin/bash

# ===============================================
# Garage S3 Server Setup Script for openSUSE/SLES
# ===============================================

set -euo pipefail

# Configuration Variables
META_DIR="/mnt/garage/meta"
BACKUP_DIR="/mnt/garage/data"
S3_SERVICE="garage.service"
GARAGE_VER="${garage_version}"
BUCKET_NAME="${bucket_name}"
S3_REGION="${bucket_region}"
KEY_NAME="harvbucketkey"

# Detect the VM IP address
SRV_IP=$(hostname -I | awk '{print $1}')

# Create RPC Secret
RPC_SECRET=$(openssl rand -hex 32)

echo "--- Starting Garage S3 Server Configuration ---" >> /opt/script-status.txt

# 1. Create the directories to store data
echo "[1/7] Creating directories..." >> /opt/script-status.txt
mkdir -p "$META_DIR"
mkdir -p "$BACKUP_DIR"

# 2. Set directory permissions
echo "[2/7] Setting permissions..." >> /opt/script-status.txt
chown -R root:root "$META_DIR"
chmod -R 700 "$META_DIR"
chown -R root:root "$BACKUP_DIR"
chmod -R 700 "$BACKUP_DIR"

# 3. Install Garage S3 binary
echo "[3/7] Installing Garage S3..." >> /opt/script-status.txt
wget -q -O garage "$GARAGE_VER"
if [ $? -ne 0 ]; then
  echo "Error: Failed to download Garage binary. Check the URL and network connectivity." >> /opt/script-status.txt
  exit 1
fi
chmod +x garage
mv garage /usr/local/bin/

# 4. Create systemd service file
echo "[4/7] Creating Systemd Service..." >> /opt/script-status.txt
cat > /etc/systemd/system/garage.service <<SERVICEFILE
[Unit]
Description=Garage S3 Storage Server
After=network.target

[Service]
ExecStart=/usr/local/bin/garage server
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICEFILE

# 5. Create Garage configuration file
echo "[5/7] Creating Garage configuration..." >> /opt/script-status.txt
cat > /etc/garage.toml <<GARAGECONF
metadata_dir = "$META_DIR"
data_dir = "$BACKUP_DIR"
db_engine = "lmdb"

replication_factor = 1

rpc_bind_addr = "[::]:3901"
rpc_public_addr = "$SRV_IP:3901"
rpc_secret = "$RPC_SECRET"

[s3_api]
s3_region = "$S3_REGION"
api_bind_addr = "[::]:3900"
root_domain = ".s3.garage.localhost"

[s3_web]
bind_addr = "[::]:3902"
root_domain = ".web.garage.localhost"
index = "index.html"

[k2v_api]
api_bind_addr = "[::]:3904"

[admin]
api_bind_addr = "[::]:3903"
admin_token = "$(openssl rand -hex 32)"
GARAGECONF

# 6. Start Garage service
echo "[6/7] Starting Garage service..." >> /opt/script-status.txt
systemctl daemon-reload
systemctl restart $S3_SERVICE
systemctl enable  $S3_SERVICE 
sleep 5

# Check if service is running
if systemctl is-active --quiet "$S3_SERVICE"; then
  echo "  $S3_SERVICE is running." >> /opt/script-status.txt
else
  echo "  $S3_SERVICE is NOT running. Check logs with: journalctl -u $S3_SERVICE" >> /opt/script-status.txt
  exit 1
fi
sleep 5

# 7. Initialize Layout and create bucket
echo "[7/7] Initializing Garage Layout..." >> /opt/script-status.txt
NODE_ID=$(garage status | grep -Ev 'ID|==' | awk '{print $1}')
garage layout assign -z Zone1 -c 50G "$NODE_ID" > /dev/null 2>&1
sleep 2
garage layout apply --version 1 > /dev/null 2>&1
sleep 2

# Create Bucket and Keys
garage bucket create "$BUCKET_NAME" > /dev/null 2>&1
KEY_OUTPUT=$(garage key create "$KEY_NAME")
garage bucket allow --read --write --owner "$BUCKET_NAME" --key "$KEY_NAME" > /dev/null 2>&1

# Extract keys
ACCESS_KEY=$(echo "$KEY_OUTPUT" | grep "Key ID" | awk '{print $3}')
SECRET_KEY=$(echo "$KEY_OUTPUT" | grep "Secret key" | awk '{print $3}')

echo "Configuration completed successfully!" >> /opt/script-status.txt

cat > /opt/harvester-s3bucket-settings.txt <<SETTINGS
Harvester S3 Bucket Settings:
Endpoint          = http://$SRV_IP:3900
Bucket Name       = $BUCKET_NAME
Bucket Region     = $S3_REGION
Access Key ID     = $ACCESS_KEY
Secret Access Key = $SECRET_KEY
SETTINGS
