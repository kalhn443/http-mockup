FROM nginx:alpine

# Install supervisor และ wget
RUN apk add --no-cache supervisor wget curl

# Download Smocker binary
RUN wget -O /usr/local/bin/smocker https://github.com/smocker-dev/smocker/releases/latest/download/smocker-linux-amd64 \
    && chmod +x /usr/local/bin/smocker

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create supervisor configuration
RUN mkdir -p /etc/supervisor/conf.d /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create smocker data directory
RUN mkdir -p /data

# Expose port for Render (Render จะ assign PORT environment variable)
EXPOSE $PORT

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:$PORT/health || exit 1

# Start script to handle dynamic port
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]