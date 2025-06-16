#!/bin/sh

# Render จะ set PORT environment variable
PORT=${PORT:-10000}

echo "Starting Smocker with reverse proxy on port $PORT"

# อัปเดต nginx config ให้ใช้ PORT ที่ถูกต้อง
sed -i "s/listen 10000;/listen $PORT;/" /etc/nginx/nginx.conf

# ตรวจสอบ nginx config
nginx -t

# สร้าง log directories
mkdir -p /var/log/supervisor /var/log/nginx

# Set Smocker environment variables
export SMOCKER_MOCK_SERVER_LISTEN_PORT=8080
export SMOCKER_CONFIG_LISTEN_PORT=8081
export SMOCKER_LOG_LEVEL=info

echo "Configuration ready. Starting services..."

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf