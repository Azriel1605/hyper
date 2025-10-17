#!/bin/bash

# Setup SSL dengan Let's Encrypt (Certbot)

DOMAIN="your-domain.com"  # Ganti dengan domain Anda

echo "🔒 Setup SSL dengan Let's Encrypt..."

# Install certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Generate SSL certificate
sudo certbot certonly --nginx -d $DOMAIN -d www.$DOMAIN

# Update nginx config untuk HTTPS
sudo tee /etc/nginx/sites-available/hdsc-app > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    client_max_body_size 10M;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
    }

    location /static/ {
        alias /var/www/hdsc-app/static/;
        expires 30d;
    }

    gzip on;
    gzip_types text/plain text/css text/javascript application/json;
}
EOF

sudo nginx -t
sudo systemctl reload nginx

# Setup auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

echo "✅ SSL setup selesai!"
