#!/bin/bash

# HDSC Deployment Script untuk Ubuntu dengan Nginx (menggunakan IP VPS)
# Jalankan sebagai root: bash deploy-ubuntu-ip.sh

set -e

echo "=========================================="
echo "HDSC Deployment untuk Ubuntu + Nginx + IP"
echo "=========================================="

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Konfigurasi
APP_DIR="/var/www/hyper-app"
APP_USER="hyper"
APP_GROUP="hyper"
VENV_DIR="$APP_DIR/venv"

# Dapatkan IP VPS
VPS_IP=$(hostname -I | awk '{print $1}')

echo -e "${YELLOW}IP VPS Anda: $VPS_IP${NC}"
echo -e "${YELLOW}Aplikasi akan diakses di: http://$VPS_IP${NC}"

echo -e "${GREEN}[1/9] Konfigurasi mirror Ubuntu...${NC}"
cat > /etc/apt/sources.list << EOF
deb http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-backports main restricted universe multiverse
EOF

# Update sistem dengan retry logic
echo -e "${GREEN}[2/9] Update sistem...${NC}"
for i in {1..3}; do
    if apt-get update; then
        break
    else
        echo -e "${YELLOW}Retry update ($i/3)...${NC}"
        sleep 5
    fi
done

apt-get upgrade -y || true

echo -e "${GREEN}[3/9] Install dependencies...${NC}"

# Cek Python versi yang tersedia
PYTHON_VERSION=""
for version in python3.12 python3.11 python3.10 python3.9; do
    if apt-cache search "^${version}$" | grep -q .; then
        PYTHON_VERSION=$version
        echo -e "${GREEN}Menggunakan $PYTHON_VERSION${NC}"
        break
    fi
done

if [ -z "$PYTHON_VERSION" ]; then
    echo -e "${RED}Tidak ada Python 3.9+ yang tersedia${NC}"
    exit 1
fi

# Install dependencies dengan error handling
apt-get install -y \
    $PYTHON_VERSION \
    ${PYTHON_VERSION}-venv \
    python3-pip \
    nginx \
    supervisor \
    git \
    curl \
    wget \
    build-essential \
    libssl-dev \
    libffi-dev || {
    echo -e "${RED}Gagal install dependencies${NC}"
    exit 1
}

# 4. Buat user aplikasi (jika belum ada)
echo -e "${GREEN}[4/9] Setup user aplikasi...${NC}"
if ! id "$APP_USER" &>/dev/null; then
    useradd -m -s /bin/bash $APP_USER
    echo -e "${GREEN}User $APP_USER dibuat${NC}"
else
    echo -e "${YELLOW}User $APP_USER sudah ada${NC}"
fi

# 5. Setup direktori aplikasi
echo -e "${GREEN}[5/9] Setup direktori aplikasi...${NC}"
mkdir -p $APP_DIR
chown -R $APP_USER:$APP_GROUP $APP_DIR

# 6. Setup Python virtual environment
echo -e "${GREEN}[6/9] Setup Python virtual environment...${NC}"
cd $APP_DIR
sudo -u $APP_USER $PYTHON_VERSION -m venv $VENV_DIR
sudo -u $APP_USER $VENV_DIR/bin/pip install --upgrade pip setuptools wheel

# 7. Install Python dependencies
echo -e "${GREEN}[7/9] Install Python dependencies...${NC}"
if [ -f "$APP_DIR/requirements.txt" ]; then
    sudo -u $APP_USER $VENV_DIR/bin/pip install -r $APP_DIR/requirements.txt
else
    echo -e "${RED}requirements.txt tidak ditemukan di $APP_DIR${NC}"
    exit 1
fi

# 8. Setup Supervisor
echo -e "${GREEN}[8/9] Setup Supervisor...${NC}"
mkdir -p $APP_DIR/logs
chown -R $APP_USER:$APP_GROUP $APP_DIR/logs

cat > /etc/supervisor/conf.d/hdsc.conf << EOF
[program:hdsc]
directory=$APP_DIR
command=$VENV_DIR/bin/gunicorn --workers 4 --bind 127.0.0.1:8000 app:app
user=$APP_USER
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=$APP_DIR/logs/gunicorn.log
environment=PATH="$VENV_DIR/bin"
EOF

supervisorctl reread
supervisorctl update
supervisorctl start hdsc

# 9. Setup Nginx
echo -e "${GREEN}[9/9] Setup Nginx...${NC}"
cat > /etc/nginx/sites-available/hdsc << EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    server_name _;
    
    # Logging
    access_log $APP_DIR/logs/nginx_access.log;
    error_log $APP_DIR/logs/nginx_error.log;
    
    # Ukuran upload maksimal
    client_max_body_size 50M;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
        
        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Static files
    location /static/ {
        alias $APP_DIR/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Enable site
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/hdsc /etc/nginx/sites-enabled/hdsc

# Test Nginx config
nginx -t

# Restart Nginx
systemctl restart nginx
systemctl enable nginx

echo ""
echo -e "${GREEN}=========================================="
echo "✓ Deployment Selesai!"
echo "==========================================${NC}"
echo ""
echo -e "${YELLOW}Akses aplikasi di:${NC}"
echo -e "${GREEN}http://$VPS_IP${NC}"
echo ""
echo -e "${YELLOW}Perintah berguna:${NC}"
echo "  - Lihat status: supervisorctl status hdsc"
echo "  - Restart app: supervisorctl restart hdsc"
echo "  - Lihat log: tail -f $APP_DIR/logs/gunicorn.log"
echo "  - Restart Nginx: systemctl restart nginx"
echo ""
echo -e "${YELLOW}Catatan:${NC}"
echo "  - Pastikan port 80 terbuka di firewall"
echo "  - Untuk HTTPS, gunakan script setup-ssl-ubuntu.sh"
echo ""
