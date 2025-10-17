# Panduan Deployment HDSC ke Ubuntu VPS (Menggunakan IP Address)

## Prasyarat
- VPS Ubuntu 20.04 atau lebih baru
- Akses root ke VPS
- Minimal 1GB RAM, 10GB storage

## Langkah-Langkah Deployment

### 1. Persiapan di Local Machine

\`\`\`bash
# Clone atau upload project ke VPS
# Opsi A: Menggunakan Git
git clone <repository-url> /var/www/hdsc-app

# Opsi B: Menggunakan SCP
scp -r ./hdsc-app root@<IP_VPS>:/var/www/
\`\`\`

### 2. Login ke VPS

\`\`\`bash
ssh root@<IP_VPS>
# Ganti <IP_VPS> dengan IP address VPS Anda
\`\`\`

### 3. Jalankan Script Deployment

\`\`\`bash
cd /var/www/hdsc-app
bash deploy-ubuntu-ip.sh
\`\`\`

Script ini akan:
- ✓ Update sistem Ubuntu
- ✓ Install dependencies (Python, Nginx, Supervisor)
- ✓ Setup Python virtual environment
- ✓ Install Python packages dari requirements.txt
- ✓ Setup Supervisor untuk process management
- ✓ Setup Nginx sebagai reverse proxy
- ✓ Konfigurasi logging

### 4. Verifikasi Deployment

\`\`\`bash
# Cek status aplikasi
supervisorctl status hdsc

# Cek status Nginx
systemctl status nginx

# Lihat log aplikasi
tail -f /var/www/hdsc-app/logs/gunicorn.log

# Lihat log Nginx
tail -f /var/www/hdsc-app/logs/nginx_access.log
\`\`\`

### 5. Akses Aplikasi

Buka browser dan akses:
\`\`\`
http://<IP_VPS>
\`\`\`

Ganti `<IP_VPS>` dengan IP address VPS Anda.

## Konfigurasi Environment Variables

### 1. Buat file .env

\`\`\`bash
nano /var/www/hdsc-app/.env
\`\`\`

### 2. Isi dengan konfigurasi Anda

\`\`\`
FLASK_ENV=production
FLASK_DEBUG=False
SECRET_KEY=your-secret-key-here
MODEL_PATH=/var/www/hdsc-app/model/model.pkl
\`\`\`

### 3. Restart aplikasi

\`\`\`bash
supervisorctl restart hdsc
\`\`\`

## Perintah Berguna

### Manage Aplikasi

\`\`\`bash
# Restart aplikasi
supervisorctl restart hdsc

# Stop aplikasi
supervisorctl stop hdsc

# Start aplikasi
supervisorctl start hdsc

# Lihat status
supervisorctl status hdsc
\`\`\`

### Manage Nginx

\`\`\`bash
# Restart Nginx
systemctl restart nginx

# Stop Nginx
systemctl stop nginx

# Start Nginx
systemctl start nginx

# Test konfigurasi
nginx -t
\`\`\`

### Lihat Log

\`\`\`bash
# Log aplikasi (real-time)
tail -f /var/www/hdsc-app/logs/gunicorn.log

# Log Nginx access
tail -f /var/www/hdsc-app/logs/nginx_access.log

# Log Nginx error
tail -f /var/www/hdsc-app/logs/nginx_error.log

# Lihat 100 baris terakhir
tail -100 /var/www/hdsc-app/logs/gunicorn.log
\`\`\`

## Troubleshooting

### Aplikasi tidak berjalan

\`\`\`bash
# Cek status
supervisorctl status hdsc

# Lihat error log
tail -f /var/www/hdsc-app/logs/gunicorn.log

# Restart
supervisorctl restart hdsc
\`\`\`

### Nginx error

\`\`\`bash
# Test konfigurasi
nginx -t

# Lihat error log
tail -f /var/www/hdsc-app/logs/nginx_error.log

# Restart Nginx
systemctl restart nginx
\`\`\`

### Port 80 sudah digunakan

\`\`\`bash
# Cari proses yang menggunakan port 80
lsof -i :80

# Kill proses (jika perlu)
kill -9 <PID>
\`\`\`

### Firewall

\`\`\`bash
# Buka port 80
ufw allow 80/tcp

# Buka port 443 (untuk HTTPS nanti)
ufw allow 443/tcp

# Lihat status firewall
ufw status
\`\`\`

## Update Aplikasi

### 1. Upload kode terbaru

\`\`\`bash
# Dari local machine
scp -r ./hdsc-app/* root@<IP_VPS>:/var/www/hdsc-app/
\`\`\`

### 2. Install dependencies baru (jika ada)

\`\`\`bash
source /var/www/hdsc-app/venv/bin/activate
pip install -r /var/www/hdsc-app/requirements.txt
\`\`\`

### 3. Restart aplikasi

\`\`\`bash
supervisorctl restart hdsc
\`\`\`

## Backup

### Backup database dan files

\`\`\`bash
# Buat backup directory
mkdir -p /var/backups/hdsc

# Backup aplikasi
tar -czf /var/backups/hdsc/app-$(date +%Y%m%d-%H%M%S).tar.gz /var/www/hdsc-app/

# Lihat backup
ls -lh /var/backups/hdsc/
\`\`\`

## Monitoring

### Cek penggunaan resource

\`\`\`bash
# CPU dan Memory
top

# Disk usage
df -h

# Memory detail
free -h
\`\`\`

### Setup monitoring otomatis

\`\`\`bash
# Install htop untuk monitoring interaktif
apt-get install htop

# Jalankan
htop
\`\`\`

## Upgrade ke HTTPS (Opsional)

Jika Anda ingin menambahkan HTTPS dengan domain custom:

\`\`\`bash
bash setup-ssl-ubuntu.sh
\`\`\`

Namun untuk IP address, HTTPS tidak bisa digunakan (SSL memerlukan domain yang valid).

## Security Best Practices

1. **Firewall**: Hanya buka port yang diperlukan
   \`\`\`bash
   ufw allow 22/tcp  # SSH
   ufw allow 80/tcp  # HTTP
   ufw enable
   \`\`\`

2. **SSH Key**: Gunakan SSH key bukan password
   \`\`\`bash
   ssh-keygen -t rsa -b 4096
   ssh-copy-id root@<IP_VPS>
   \`\`\`

3. **Disable Root Login**: Edit `/etc/ssh/sshd_config`
   \`\`\`
   PermitRootLogin no
   \`\`\`

4. **Update Regular**: Jalankan update secara berkala
   \`\`\`bash
   apt-get update && apt-get upgrade -y
   \`\`\`

5. **Monitor Log**: Periksa log secara berkala
   \`\`\`bash
   tail -f /var/www/hdsc-app/logs/gunicorn.log
   \`\`\`

## Support

Jika ada masalah, cek:
1. Log aplikasi: `/var/www/hdsc-app/logs/gunicorn.log`
2. Log Nginx: `/var/www/hdsc-app/logs/nginx_error.log`
3. Status Supervisor: `supervisorctl status`
4. Status Nginx: `systemctl status nginx`
