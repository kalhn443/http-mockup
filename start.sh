#!/bin/sh

# Render จะ set PORT environment variable
# Default port 10000 ถ้าไม่มี PORT
PORT=${PORT:-10000}

echo "Starting services on port $PORT"

# Replace PORT placeholder in nginx.conf
envsubst '${PORT}' < /etc/nginx/nginx.conf > /tmp/nginx.conf
mv /tmp/nginx.conf /etc/nginx/nginx.conf

# Validate nginx configuration
nginx -t

# Create log directories
mkdir -p /var/log/supervisor /var/log/nginx

# Set environment variables for Smocker
export SMOCKER_MOCK_SERVER_LISTEN_PORT=8080
export SMOCKER_CONFIG_LISTEN_PORT=8081
export SMOCKER_LOG_LEVEL=info
export SMOCKER_PERSIST_SESSIONS=true
export SMOCKER_HISTORY_RETENTION=168h

# Create supervisor config with environment variables
cat > /etc/supervisor/conf.d/supervisord.conf << EOF
[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid
user=root
loglevel=info

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/nginx.err.log
stdout_logfile=/var/log/supervisor/nginx.out.log
priority=999
startretries=3

[program:smocker]
command=/usr/local/bin/smocker
directory=/data
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/smocker.err.log
stdout_logfile=/var/log/supervisor/smocker.out.log
environment=SMOCKER_MOCK_SERVER_LISTEN_PORT=8080,SMOCKER_CONFIG_LISTEN_PORT=8081,SMOCKER_LOG_LEVEL=info,SMOCKER_PERSIST_SESSIONS=true,SMOCKER_HISTORY_RETENTION=168h
priority=1
startretries=3
EOF

# Show configuration for debugging
echo "=== Configuration ==="
echo "PORT: $PORT"
echo "SMOCKER_MOCK_SERVER_LISTEN_PORT: $SMOCKER_MOCK_SERVER_LISTEN_PORT"
echo "SMOCKER_CONFIG_LISTEN_PORT: $SMOCKER_CONFIG_LISTEN_PORT"
echo "====================="

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf