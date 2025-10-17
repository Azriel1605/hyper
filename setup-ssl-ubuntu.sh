#!/bin/bash

# Setup SSL/HTTPS dengan Let's Encrypt untuk Ubuntu
# Usage: bash setup-ssl-ubuntu.sh

DOMAIN="your-domain.com"
EMAIL="admin@your-domain.com"

echo "🔒 Setup SSL/HTTPS dengan Let's Encrypt..."

# 1. Pastikan domain sudah pointing ke server
echo "⚠️  Pastikan domain $DOMAIN sudah pointing ke IP server ini"
read -p "Lanjutkan? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# 2. Generate SSL certificate
echo "📜 Generate SSL certificate..."
certbot certonly --nginx \
    --non-interactive \
    --agree-tos \
    --email $EMAIL \
    -d $DOMAIN \
    -d www.$DOMAIN

# 3. Update Nginx configuration
echo "⚙️ Update Nginx configuration..."
cat > /etc/nginx/sites-available/hdsc-app << 'NGINXFILE'
upstream hdsc_app {
    server 127.0.0.1:5000;
}

# Redirect HTTP ke HTTPS
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;
    client_max_body_size 10M;

    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

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

# 4. Test Nginx
echo "🔍 Test Nginx configuration..."
nginx -t

# 5. Reload Nginx
echo "🔄 Reload Nginx..."
systemctl reload nginx

# 6. Setup auto-renewal
echo "⏰ Setup auto-renewal untuk SSL..."
systemctl enable certbot.timer
systemctl start certbot.timer

echo "✅ SSL setup selesai!"
echo ""
echo "🔗 Aplikasi tersedia di: https://$DOMAIN"
echo "📜 Certificate akan auto-renew sebelum expired"
