# Panduan Deployment HDSC Flask App ke VPS

## Prasyarat
- VPS dengan Ubuntu 20.04+ atau Debian 10+
- SSH access ke VPS
- Domain (opsional, untuk SSL)
- Model ML di `model/model.pkl`

## Langkah-Langkah Deployment

### 1. Persiapan Lokal
\`\`\`bash
# Clone repository
git clone <your-repo-url>
cd hdsc-app

# Pastikan semua file ada
ls -la app.py requirements.txt templates/ static/ model/
\`\`\`

### 2. Setup VPS (Otomatis)
\`\`\`bash
# Jalankan script deployment
bash deploy.sh <server_ip> <username>

# Contoh:
bash deploy.sh 192.168.1.100 ubuntu
\`\`\`

### 3. Konfigurasi Manual di VPS
\`\`\`bash
# SSH ke server
ssh ubuntu@192.168.1.100

# Edit environment variables
nano /var/www/hdsc-app/.env

# Pastikan model ada
ls -la /var/www/hdsc-app/model/model.pkl
\`\`\`

### 4. Setup Supervisor (Process Manager)
\`\`\`bash
bash setup-supervisor.sh

# Cek status
sudo supervisorctl status hdsc-app
\`\`\`

### 5. Setup Nginx (Web Server)
\`\`\`bash
# Edit domain di script
nano setup-nginx.sh  # Ganti 'your-domain.com'

bash setup-nginx.sh

# Test
curl http://localhost
\`\`\`

### 6. Setup SSL (Opsional tapi Recommended)
\`\`\`bash
# Edit domain di script
nano setup-ssl.sh  # Ganti 'your-domain.com'

bash setup-ssl.sh
\`\`\`

## Struktur Direktori di VPS
\`\`\`
/var/www/hdsc-app/
├── app.py
├── requirements.txt
├── .env
├── venv/                 # Virtual environment
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
│   └── model.pkl
└── logs/
    └── gunicorn.log
\`\`\`

## Monitoring & Maintenance

### Cek Status Aplikasi
\`\`\`bash
# Status supervisor
sudo supervisorctl status hdsc-app

# Lihat logs
tail -f /var/www/hdsc-app/logs/gunicorn.log

# Cek nginx
sudo systemctl status nginx
\`\`\`

### Restart Aplikasi
\`\`\`bash
sudo supervisorctl restart hdsc-app
\`\`\`

### Update Aplikasi
\`\`\`bash
cd /var/www/hdsc-app
git pull origin main
source venv/bin/activate
pip install -r requirements.txt
sudo supervisorctl restart hdsc-app
\`\`\`

### Backup Model
\`\`\`bash
# Backup model ML
cp /var/www/hdsc-app/model/model.pkl /var/www/hdsc-app/model/model.pkl.backup
\`\`\`

## Troubleshooting

### Aplikasi tidak berjalan
\`\`\`bash
# Cek logs
sudo supervisorctl tail hdsc-app stderr

# Restart
sudo supervisorctl restart hdsc-app
\`\`\`

### Port 5000 sudah digunakan
\`\`\`bash
# Cari proses yang menggunakan port 5000
sudo lsof -i :5000

# Kill proses
sudo kill -9 <PID>
\`\`\`

### Nginx error
\`\`\`bash
# Test konfigurasi
sudo nginx -t

# Reload
sudo systemctl reload nginx
\`\`\`

### Model tidak ditemukan
\`\`\`bash
# Pastikan file ada
ls -la /var/www/hdsc-app/model/model.pkl

# Jika tidak ada, upload model
scp model/model.pkl ubuntu@192.168.1.100:/var/www/hdsc-app/model/
\`\`\`

## Performance Tuning

### Increase Gunicorn Workers
Edit `/etc/supervisor/conf.d/hdsc-app.conf`:
\`\`\`
command=/var/www/hdsc-app/venv/bin/gunicorn --workers 8 --worker-class sync --bind 127.0.0.1:5000 app:app
\`\`\`

### Enable Caching
Nginx sudah dikonfigurasi untuk cache static files (30 hari).

### Database Connection Pooling
Jika menggunakan database, tambahkan connection pooling di app.py.

## Security Best Practices

1. ✅ Gunakan HTTPS (SSL/TLS)
2. ✅ Set `SECRET_KEY` yang kuat di `.env`
3. ✅ Disable debug mode di production (`FLASK_ENV=production`)
4. ✅ Gunakan firewall (UFW)
5. ✅ Regular backup model dan data
6. ✅ Monitor logs untuk suspicious activity

## Firewall Setup (UFW)
\`\`\`bash
sudo ufw enable
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw status
\`\`\`

## Support & Debugging
- Cek logs: `tail -f /var/www/hdsc-app/logs/gunicorn.log`
- Cek nginx: `sudo tail -f /var/log/nginx/error.log`
- Cek supervisor: `sudo supervisorctl tail hdsc-app stderr`
