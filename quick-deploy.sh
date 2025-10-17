#!/bin/bash

# Quick Deploy Script - untuk upload dan deploy cepat
# Gunakan: bash quick-deploy.sh <IP_VPS> <SSH_USER>

if [ $# -lt 2 ]; then
    echo "Penggunaan: bash quick-deploy.sh <IP_VPS> <SSH_USER>"
    echo "Contoh: bash quick-deploy.sh 192.168.1.100 root"
    exit 1
fi

VPS_IP=$1
SSH_USER=$2
APP_DIR="/var/www/hdsc-app"

echo "=========================================="
echo "Quick Deploy HDSC ke VPS"
echo "=========================================="
echo "IP VPS: $VPS_IP"
echo "User: $SSH_USER"
echo ""

# 1. Upload project
echo "[1/3] Upload project ke VPS..."
ssh $SSH_USER@$VPS_IP "mkdir -p $APP_DIR"
scp -r . $SSH_USER@$VPS_IP:$APP_DIR/

# 2. Jalankan deployment script
echo "[2/3] Menjalankan deployment script..."
ssh $SSH_USER@$VPS_IP "cd $APP_DIR && bash deploy-ubuntu-ip.sh"

# 3. Verifikasi
echo "[3/3] Verifikasi deployment..."
sleep 5
curl -s http://$VPS_IP | head -20

echo ""
echo "✓ Deploy selesai!"
echo "Akses aplikasi di: http://$VPS_IP"
