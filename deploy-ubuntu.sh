#!/bin/bash

# Script deployment HDSC Flask App ke Ubuntu VPS dengan Nginx
# Usage: bash deploy-ubuntu.sh
# Jalankan sebagai root atau dengan sudo

set -e

APP_DIR="/var/www/hdsc-app"
APP_USER="www-data"
DOMAIN="your-domain.com"  # Ganti dengan domain Anda

echo "🚀 Memulai deployment HDSC ke Ubuntu dengan Nginx..."

# 1. Update sistem
echo "📦 Update sistem..."
apt-get update
apt-get upgrade -y

# 2. Install dependencies
echo "📦 Install dependencies..."
apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    nginx \
    supervisor \
    git \
    curl \
    certbot \
    python3-certbot-nginx

# 3. Buat direktori aplikasi
echo "📁 Setup direktori aplikasi..."
mkdir -p $APP_DIR
mkdir -p $APP_DIR/logs

# 4. Clone/setup repository
echo "🔄 Setup repository..."
if [ ! -d "$APP_DIR/.git" ]; then
    echo "⚠️  Silakan upload project ke $APP_DIR terlebih dahulu"
    echo "   Gunakan: scp -r ./hdsc-app/* root@your-ip:$APP_DIR/"
    exit 1
fi

# 5. Setup Python virtual environment
echo "🐍 Setup Python virtual environment..."
cd $APP_DIR
python3 -m venv venv
source venv/bin/activate

# 6. Install Python dependencies
echo "📥 Install Python dependencies..."
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
pip install gunicorn

# 7. Setup environment variables
echo "⚙️ Setup environment variables..."
if [ ! -f .env ]; then
    cat > .env << 'ENVFILE'
FLASK_ENV=production
SECRET_KEY=your-secret-key-change-this-to-random-string
MODEL_PATH=/var/www/hdsc-app/model/model.pkl
PORT=5000
ENVFILE
    echo "⚠️  Edit .env dengan konfigurasi yang sesuai!"
fi

# 8. Setup Supervisor untuk process management
echo "⚙️ Setup Supervisor..."
cat > /etc/supervisor/conf.d/hdsc-app.conf << 'SUPERVISORFILE'
[program:hdsc-app]
directory=/var/www/hdsc-app
command=/var/www/hdsc-app/venv/bin/gunicorn --workers 4 --worker-class sync --bind 127.0.0.1:5000 --timeout 60 app:app
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/www/hdsc-app/logs/gunicorn.log
environment=PATH="/var/www/hdsc-app/venv/bin",FLASK_ENV="production"
SUPERVISORFILE

# 9. Setup Nginx
echo "⚙️ Setup Nginx..."
cat > /etc/nginx/sites-available/hdsc-app << 'NGINXFILE'
upstream hdsc_app {
    server 127.0.0.1:5000;
}

server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    client_max_body_size 10M;

    # Redirect HTTP ke HTTPS (uncomment setelah SSL setup)
    # return 301 https://$server_name$request_uri;

    location / {
        proxy_pass http://hdsc_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    location /static/ {
        alias /var/www/hdsc-app/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location /model/ {
        deny all;
    }
}
NGINXFILE

# 10. Enable Nginx site
ln -sf /etc/nginx/sites-available/hdsc-app /etc/nginx/sites-enabled/hdsc-app
rm -f /etc/nginx/sites-enabled/default

# 11. Test Nginx configuration
echo "🔍 Test Nginx configuration..."
nginx -t

# 12. Set permissions
echo "🔐 Set permissions..."
chown -R www-data:www-data $APP_DIR
chmod -R 755 $APP_DIR
chmod -R 755 $APP_DIR/logs

# 13. Start services
echo "🚀 Start services..."
systemctl restart supervisor
systemctl restart nginx
systemctl enable supervisor
systemctl enable nginx

# 14. Check status
echo "✅ Deployment selesai!"
echo ""
echo "📊 Status services:"
supervisorctl status hdsc-app
systemctl status nginx --no-pager | head -5

echo ""
echo "🔗 Aplikasi tersedia di: http://your-domain.com"
echo ""
echo "📝 Langkah selanjutnya:"
echo "   1. Edit .env: nano $APP_DIR/.env"
echo "   2. Setup SSL: bash setup-ssl-ubuntu.sh"
echo "   3. Monitor logs: tail -f $APP_DIR/logs/gunicorn.log"
