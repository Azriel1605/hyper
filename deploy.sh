#!/bin/bash

# Script deployment HDSC Flask App ke VPS
# Usage: bash deploy.sh <server_ip> <username>

set -e

SERVER_IP=${1:-localhost}
USERNAME=${2:-root}
APP_DIR="/var/www/hdsc-app"
REPO_URL="your-repo-url-here"  # Ganti dengan URL repo Anda

echo "🚀 Memulai deployment ke $SERVER_IP..."

# 1. SSH ke server dan setup
ssh $USERNAME@$SERVER_IP << 'EOF'
  echo "📦 Menginstall dependencies sistem..."
  sudo apt-get update
  sudo apt-get install -y python3 python3-pip python3-venv nginx supervisor git

  echo "📁 Membuat direktori aplikasi..."
  sudo mkdir -p $APP_DIR
  sudo chown $USERNAME:$USERNAME $APP_DIR

  echo "🔄 Clone/update repository..."
  if [ -d "$APP_DIR/.git" ]; then
    cd $APP_DIR && git pull origin main
  else
    git clone $REPO_URL $APP_DIR
  fi

  echo "🐍 Setup Python virtual environment..."
  cd $APP_DIR
  python3 -m venv venv
  source venv/bin/activate

  echo "📥 Install Python dependencies..."
  pip install --upgrade pip
  pip install -r requirements.txt
  pip install gunicorn

  echo "⚙️ Setup environment variables..."
  if [ ! -f .env ]; then
    cp .env.example .env
    echo "⚠️  Edit .env dengan konfigurasi yang sesuai!"
  fi

  echo "✅ Setup selesai!"
EOF

echo "✅ Deployment selesai! Lanjutkan dengan:"
echo "   1. Edit .env di server: ssh $USERNAME@$SERVER_IP"
echo "   2. Setup supervisor: bash setup-supervisor.sh"
echo "   3. Setup nginx: bash setup-nginx.sh"
