# Panduan Deployment HDSC ke Ubuntu VPS dengan Nginx

## 📋 Prasyarat
- VPS Ubuntu 20.04+ atau 22.04
- SSH access sebagai root
- Domain (opsional, untuk SSL)
- Model ML di `model/model.pkl`

## 🚀 Langkah-Langkah Deployment

### 1. Upload Project ke VPS
\`\`\`bash
# Dari local machine
scp -r ./hdsc-app/* root@your-ip:/var/www/hdsc-app/

# Atau gunakan git
ssh root@your-ip
cd /var/www/hdsc-app
git clone your-repo-url .
\`\`\`

### 2. Jalankan Script Deployment
\`\`\`bash
# SSH ke server
ssh root@your-ip

# Jalankan script deployment
bash /var/www/hdsc-app/deploy-ubuntu.sh
\`\`\`

### 3. Edit Environment Variables
\`\`\`bash
nano /var/www/hdsc-app/.env

# Ubah:
# - SECRET_KEY: ganti dengan string random yang kuat
# - MODEL_PATH: pastikan path ke model.pkl benar
# - FLASK_ENV: production
\`\`\`

### 4. Update Nginx Configuration
\`\`\`bash
# Edit domain di Nginx config
nano /etc/nginx/sites-available/hdsc-app

# Ganti "your-domain.com" dengan domain Anda
# Lalu reload Nginx
systemctl reload nginx
\`\`\`

### 5. Setup SSL/HTTPS (Recommended)
\`\`\`bash
# Edit domain di script
nano /var/www/hdsc-app/setup-ssl-ubuntu.sh

# Jalankan script
bash /var/www/hdsc-app/setup-ssl-ubuntu.sh
\`\`\`

## 📁 Struktur Direktori
\`\`\`
/var/www/hdsc-app/
├── app.py                    # Flask application
├── requirements.txt          # Python dependencies
├── .env                      # Environment variables
├── venv/                     # Virtual environment
├── templates/
│   ├── base.html
│   ├── index.html
│   ├── test.html
│   └── result.html
├── static/
│   ├── css/
│   ├── js/
│   └── images/
├── model/
│   └── model.pkl            # Model ML
├── logs/
│   └── gunicorn.log         # Application logs
├── deploy-ubuntu.sh         # Deployment script
├── setup-ssl-ubuntu.sh      # SSL setup script
└── maintenance-ubuntu.sh    # Maintenance script
\`\`\`

## 🔧 Maintenance & Monitoring

### Cek Status
\`\`\`bash
bash /var/www/hdsc-app/maintenance-ubuntu.sh status
\`\`\`

### Lihat Logs Real-time
\`\`\`bash
bash /var/www/hdsc-app/maintenance-ubuntu.sh logs
\`\`\`

### Restart Aplikasi
\`\`\`bash
bash /var/www/hdsc-app/maintenance-ubuntu.sh restart
\`\`\`

### Update Aplikasi
\`\`\`bash
bash /var/www/hdsc-app/maintenance-ubuntu.sh update
\`\`\`

### Backup Model
\`\`\`bash
bash /var/www/hdsc-app/maintenance-ubuntu.sh backup
\`\`\`

## 🔍 Troubleshooting

### Aplikasi tidak berjalan
\`\`\`bash
# Cek logs
tail -f /var/www/hdsc-app/logs/gunicorn.log

# Cek status supervisor
supervisorctl status hdsc-app

# Restart
supervisorctl restart hdsc-app
\`\`\`

### Nginx error
\`\`\`bash
# Test konfigurasi
nginx -t

# Lihat error logs
tail -f /var/log/nginx/error.log

# Reload
systemctl reload nginx
\`\`\`

### Port sudah digunakan
\`\`\`bash
# Cari proses di port 5000
lsof -i :5000

# Kill proses
kill -9 <PID>
\`\`\`

### Model tidak ditemukan
\`\`\`bash
# Pastikan file ada
ls -la /var/www/hdsc-app/model/model.pkl

# Jika tidak ada, upload
scp model/model.pkl root@your-ip:/var/www/hdsc-app/model/
\`\`\`

## 🔐 Security Best Practices

1. ✅ Gunakan HTTPS/SSL
2. ✅ Set SECRET_KEY yang kuat
3. ✅ Disable debug mode (FLASK_ENV=production)
4. ✅ Setup firewall UFW
5. ✅ Regular backup
6. ✅ Monitor logs

### Setup Firewall UFW
\`\`\`bash
ufw enable
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw status
\`\`\`

## 📊 Performance Tuning

### Increase Gunicorn Workers
Edit `/etc/supervisor/conf.d/hdsc-app.conf`:
\`\`\`
command=/var/www/hdsc-app/venv/bin/gunicorn --workers 8 --bind 127.0.0.1:5000 app:app
\`\`\`

Lalu restart:
\`\`\`bash
supervisorctl restart hdsc-app
\`\`\`

### Enable Gzip Compression
Sudah dikonfigurasi di Nginx untuk static files.

## 🆘 Support

- Logs aplikasi: `/var/www/hdsc-app/logs/gunicorn.log`
- Logs Nginx: `/var/log/nginx/error.log`
- Logs Supervisor: `supervisorctl tail hdsc-app stderr`
