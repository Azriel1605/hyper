#!/bin/bash

# Script maintenance untuk Ubuntu deployment
# Usage: bash maintenance-ubuntu.sh [command]

APP_DIR="/var/www/hdsc-app"

case "$1" in
    status)
        echo "📊 Status aplikasi:"
        supervisorctl status hdsc-app
        echo ""
        echo "📊 Status Nginx:"
        systemctl status nginx --no-pager | head -5
        ;;
    logs)
        echo "📋 Gunicorn logs:"
        tail -f $APP_DIR/logs/gunicorn.log
        ;;
    restart)
        echo "🔄 Restart aplikasi..."
        supervisorctl restart hdsc-app
        echo "✅ Aplikasi di-restart"
        ;;
    update)
        echo "🔄 Update aplikasi..."
        cd $APP_DIR
        git pull origin main
        source venv/bin/activate
        pip install -r requirements.txt
        supervisorctl restart hdsc-app
        echo "✅ Aplikasi di-update"
        ;;
    backup)
        echo "💾 Backup model..."
        cp $APP_DIR/model/model.pkl $APP_DIR/model/model.pkl.backup.$(date +%Y%m%d_%H%M%S)
        echo "✅ Backup selesai"
        ;;
    *)
        echo "Usage: bash maintenance-ubuntu.sh [command]"
        echo ""
        echo "Commands:"
        echo "  status   - Lihat status aplikasi"
        echo "  logs     - Lihat logs real-time"
        echo "  restart  - Restart aplikasi"
        echo "  update   - Update aplikasi dari git"
        echo "  backup   - Backup model ML"
        ;;
esac
