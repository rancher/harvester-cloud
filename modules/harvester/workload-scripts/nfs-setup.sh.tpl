#!/bin/bash

# ============================================
# NFS Server Setup Script for openSUSE/SLES
# ============================================

set -euo pipefail

# Configuration Variables
NFS_EXPORT_PATH="${nfs_export_path}"
NFS_EXPORT_OPTIONS="${nfs_export_options}"
NFS_DATA_DISK="/dev/vdb"
NFS_MOUNT_POINT="/mnt/nfs-data"
NFS_SERVICE="nfsserver"

echo "--- Starting NFS Server Configuration ---" >> /opt/script-status.txt

# 1. Wait for the data disk to be available
echo "[1/6] Waiting for data disk $NFS_DATA_DISK..." >> /opt/script-status.txt
RETRIES=0
until [ -b "$NFS_DATA_DISK" ] || [ $RETRIES -ge 30 ]; do
  sleep 5
  RETRIES=$((RETRIES + 1))
done

if [ ! -b "$NFS_DATA_DISK" ]; then
  echo "  ERROR: Data disk $NFS_DATA_DISK not found after waiting." >> /opt/script-status.txt
  exit 1
fi

# 2. Format the data disk (only if not already formatted)
echo "[2/6] Formatting data disk $NFS_DATA_DISK..." >> /opt/script-status.txt
if ! blkid "$NFS_DATA_DISK" &>/dev/null; then
  mkfs.ext4 -F "$NFS_DATA_DISK"
  echo "  $NFS_DATA_DISK formatted with ext4." >> /opt/script-status.txt
else
  echo "  $NFS_DATA_DISK is already formatted, skipping." >> /opt/script-status.txt
fi

# 3. Mount the data disk
echo "[3/6] Mounting data disk..." >> /opt/script-status.txt
mkdir -p "$NFS_MOUNT_POINT"
DISK_UUID=$(blkid -s UUID -o value "$NFS_DATA_DISK")

if ! grep -q "$DISK_UUID" /etc/fstab; then
  echo "UUID=$DISK_UUID $NFS_MOUNT_POINT ext4 defaults 0 2" >> /etc/fstab
fi

mount -a
echo "  $NFS_DATA_DISK mounted at $NFS_MOUNT_POINT." >> /opt/script-status.txt

# 4. Create and configure the NFS export directory
echo "[4/6] Configuring NFS export directory..." >> /opt/script-status.txt
mkdir -p "$NFS_EXPORT_PATH"

# Ensure the export path is on or under the mount point
if [[ "$NFS_EXPORT_PATH" != "$NFS_MOUNT_POINT"* ]]; then
  # Export path is not on the data disk, bind mount the data disk to the export path
  mount --bind "$NFS_MOUNT_POINT" "$NFS_EXPORT_PATH"
fi

chmod 0755 "$NFS_EXPORT_PATH"

# 5. Configure /etc/exports
echo "[5/6] Configuring /etc/exports..." >> /opt/script-status.txt
if ! grep -q "^$NFS_EXPORT_PATH " /etc/exports 2>/dev/null; then
  echo "$NFS_EXPORT_PATH $NFS_EXPORT_OPTIONS" >> /etc/exports
fi

# 6. Enable and start NFS services
echo "[6/6] Enabling and starting NFS services..." >> /opt/script-status.txt
systemctl enable --now rpcbind
systemctl enable --now "$NFS_SERVICE"
sleep 5

exportfs -a

# Verify services are running
for SVC in rpcbind "$NFS_SERVICE"; do
  if systemctl is-active --quiet "$SVC"; then
    echo "  $SVC is running." >> /opt/script-status.txt
  else
    echo "  ERROR: $SVC is NOT running. Check logs with: journalctl -u $SVC" >> /opt/script-status.txt
    exit 1
  fi
done

# Detect the VM IP address
SRV_IP=$(hostname -I | awk '{print $1}')

echo "NFS Server configuration completed successfully!" >> /opt/script-status.txt

cat > /opt/nfs-server-settings.txt <<SETTINGS
Harvester NFS Server Settings:
Server IP         = $SRV_IP
Export Path       = $NFS_EXPORT_PATH
Export Options    = $NFS_EXPORT_OPTIONS
Mount Command     = mount -t nfs $SRV_IP:$NFS_EXPORT_PATH /mnt/nfs
SETTINGS
