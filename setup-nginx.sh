#!/bin/bash

# Setup Nginx sebagai reverse proxy

DOMAIN="your-domain.com"  # Ganti dengan domain Anda
APP_DIR="/var/www/hdsc-app"

echo "⚙️ Setup Nginx untuk HDSC Flask App..."

# Buat file konfigurasi nginx
sudo tee /etc/nginx/sites-available/hdsc-app > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    # Redirect HTTP ke HTTPS (opsional, jika menggunakan SSL)
    # return 301 https://\$server_name\$request_uri;

    client_max_body_size 10M;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    location /static/ {
        alias $APP_DIR/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css text/javascript application/json;
    gzip_min_length 1000;
}
EOF

# Enable site
sudo ln -sf /etc/nginx/sites-available/hdsc-app /etc/nginx/sites-enabled/hdsc-app

# Test nginx config
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx

echo "✅ Nginx setup selesai!"
echo "📝 Ganti 'your-domain.com' di /etc/nginx/sites-available/hdsc-app"
