#!/bin/bash

# ==========================================
# Lanre's Official n8n Installer (Traefik Version)
# ==========================================

# --- 1. Check & Install Docker (Auto-Detect) ---
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing..."
    curl -fsSL https://get.docker.com | sh
else
    echo "Docker is already installed."
fi

# --- 2. Configuration Prompts ---
echo ""
echo "--- Setup Configuration ---"
read -p "Enter your Main Domain (e.g., metrohyp.com): " DOMAIN_NAME
read -p "Enter Subdomain (e.g., n8n): " SUBDOMAIN
read -p "Enter Email for SSL (e.g., admin@metrohyp.com): " SSL_EMAIL

# --- 3. Directory Setup ---
# We use absolute paths to avoid "No such file" errors
PROJECT_DIR="$HOME/n8n-compose"
mkdir -p "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/local-files"
cd "$PROJECT_DIR"

# --- 4. Create .env file ---
echo "Creating .env file..."
cat <<EOF > .env
DOMAIN_NAME=$DOMAIN_NAME
SUBDOMAIN=$SUBDOMAIN
GENERIC_TIMEZONE=Africa/Lagos
TZ=Africa/Lagos
SSL_EMAIL=$SSL_EMAIL
EOF

# --- 5. Create compose.yaml ---
echo "Creating compose.yaml file..."
cat <<EOF > compose.yaml
services:
  traefik:
    image: "traefik"
    restart: always
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.mytlschallenge.acme.tlschallenge=true"
      - "--certificatesresolvers.mytlschallenge.acme.email=\${SSL_EMAIL}"
      - "--certificatesresolvers.mytlschallenge.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - traefik_data:/letsencrypt
      - /var/run/docker.sock:/var/run/docker.sock:ro

  n8n:
    image: docker.n8n.io/n8nio/n8n
    restart: always
    ports:
      - "127.0.0.1:5678:5678"
    labels:
      - traefik.enable=true
      - traefik.http.routers.n8n.rule=Host(\`\${SUBDOMAIN}.\${DOMAIN_NAME}\`)
      - traefik.http.routers.n8n.tls=true
      - traefik.http.routers.n8n.entrypoints=web,websecure
      - traefik.http.routers.n8n.tls.certresolver=mytlschallenge
      - traefik.http.middlewares.n8n.headers.SSLRedirect=true
      - traefik.http.middlewares.n8n.headers.STSSeconds=315360000
      - traefik.http.middlewares.n8n.headers.browserXSSFilter=true
      - traefik.http.middlewares.n8n.headers.contentTypeNosniff=true
      - traefik.http.middlewares.n8n.headers.forceSTSHeader=true
      - traefik.http.middlewares.n8n.headers.SSLHost=\${DOMAIN_NAME}
      - traefik.http.middlewares.n8n.headers.STSIncludeSubdomains=true
      - traefik.http.middlewares.n8n.headers.STSPreload=true
      - traefik.http.routers.n8n.middlewares=n8n@docker
    environment:
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      - N8N_HOST=\${SUBDOMAIN}.\${DOMAIN_NAME}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - N8N_RUNNERS_ENABLED=true
      - NODE_ENV=production
      - WEBHOOK_URL=https://\${SUBDOMAIN}.\${DOMAIN_NAME}/
      - GENERIC_TIMEZONE=\${GENERIC_TIMEZONE}
      - TZ=\${GENERIC_TIMEZONE}
    volumes:
      - n8n_data:/home/node/.n8n
      - ./local-files:/files
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G

volumes:
  n8n_data:
  traefik_data:
EOF

# --- 6. Start Docker ---
echo ""
echo "--- Starting Installation ---"
docker compose up -d

echo ""
echo "SUCCESS!"
echo "Wait 30-60 seconds for SSL certificates to generate."
echo "Then access: https://\$SUBDOMAIN.\$DOMAIN_NAME"
