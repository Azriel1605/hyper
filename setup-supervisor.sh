#!/bin/bash

# Setup Supervisor untuk menjalankan Flask app sebagai service

APP_DIR="/var/www/hdsc-app"
APP_USER="www-data"

echo "⚙️ Setup Supervisor untuk HDSC Flask App..."

# Buat file konfigurasi supervisor
sudo tee /etc/supervisor/conf.d/hdsc-app.conf > /dev/null <<EOF
[program:hdsc-app]
directory=$APP_DIR
command=$APP_DIR/venv/bin/gunicorn --workers 4 --worker-class sync --bind 127.0.0.1:5000 --timeout 120 app:app
user=$APP_USER
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=$APP_DIR/logs/gunicorn.log
environment=PATH="$APP_DIR/venv/bin",FLASK_ENV="production"
EOF

# Buat direktori logs
mkdir -p $APP_DIR/logs
sudo chown $APP_USER:$APP_USER $APP_DIR/logs

# Reload supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start hdsc-app

echo "✅ Supervisor setup selesai!"
echo "📋 Cek status: sudo supervisorctl status hdsc-app"
