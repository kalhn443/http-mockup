FROM nginx:alpine

# Install supervisor และ curl
RUN apk add --no-cache supervisor curl

# Install Smocker using the official Docker image approach
# We'll extract the binary from the official image
FROM ghcr.io/smocker-dev/smocker:latest AS smocker-source

FROM nginx:alpine
# Install supervisor และ curl
RUN apk add --no-cache supervisor curl

# Copy Smocker binary from official image
COPY --from=smocker-source /opt/ /usr/local/bin/
RUN chmod +x /usr/local/bin/smocker

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