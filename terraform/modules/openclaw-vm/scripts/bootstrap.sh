#!/bin/bash
# OpenClaw Bootstrap Script
# Installs and configures OpenClaw on Ubuntu 22.04

set -e

# Variables (templated by Terraform)
GITHUB_TOKEN="${github_token}"
COPILOT_TOKEN="${copilot_token}"
AGENTS_COUNT="${agents_count}"
ENVIRONMENT="${environment}"

# Logging
exec > >(tee -a /var/log/openclaw-bootstrap.log)
exec 2>&1

echo "========================================="
echo "OpenClaw Bootstrap Script"
echo "Environment: $ENVIRONMENT"
echo "Agents: $AGENTS_COUNT"
echo "Started: $(date)"
echo "========================================="

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install dependencies
echo "Installing dependencies..."
apt-get install -y \
    curl \
    wget \
    git \
    jq \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com | bash
systemctl enable docker
systemctl start docker
usermod -aG docker azureuser

# Install Docker Compose
echo "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)
curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Node.js 20 (for OpenClaw)
echo "Installing Node.js 20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Install OpenClaw
echo "Installing OpenClaw..."
npm install -g openclaw

# Create OpenClaw directory
mkdir -p /opt/openclaw
cd /opt/openclaw

# Clone OpenClaw configuration repo
echo "Cloning OpenClaw repository..."
git clone https://github.com/appOrb/openClaw.git .

# Setup environment variables
cat > /opt/openclaw/.env <<EOF
# OpenClaw Configuration
GITHUB_TOKEN=$GITHUB_TOKEN
COPILOT_TOKEN=$COPILOT_TOKEN
AGENTS_COUNT=$AGENTS_COUNT
ENVIRONMENT=$ENVIRONMENT

# Azure Authentication
ARM_SUBSCRIPTION_ID=05a43f56-f126-4bf1-bb97-9ca4d91dfcb5
ARM_TENANT_ID=1b9184b9-e785-4727-a33d-f9526fe07006
EOF

chmod 600 /opt/openclaw/.env
chown -R azureuser:azureuser /opt/openclaw

# Install Keycloak (authentication)
echo "Setting up Keycloak..."
cd /opt/openclaw/keycloak
docker-compose up -d

# Wait for Keycloak to be ready
echo "Waiting for Keycloak..."
sleep 30

# Setup Nginx (reverse proxy)
echo "Installing Nginx..."
apt-get install -y nginx
cp /opt/openclaw/nginx/openclaw.conf /etc/nginx/sites-available/openclaw
ln -sf /etc/nginx/sites-available/openclaw /etc/nginx/sites-enabled/openclaw
rm -f /etc/nginx/sites-enabled/default

# Install Certbot (SSL certificates)
echo "Installing Certbot..."
apt-get install -y certbot python3-certbot-nginx

# Restart Nginx
systemctl restart nginx

# Create OpenClaw systemd service
echo "Creating OpenClaw service..."
cat > /etc/systemd/system/openclaw.service <<EOF
[Unit]
Description=OpenClaw AI Developer Platform
After=network.target docker.service

[Service]
Type=simple
User=azureuser
WorkingDirectory=/opt/openclaw
Environment="PATH=/usr/local/bin:/usr/bin:/bin"
EnvironmentFile=/opt/openclaw/.env
ExecStart=/usr/bin/openclaw start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start OpenClaw
systemctl daemon-reload
systemctl enable openclaw
systemctl start openclaw

# Setup Paperclip (company config)
echo "Configuring Paperclip..."
cd /opt/openclaw/paperclip
# Paperclip configuration is in company.yaml

# Create health check endpoint
echo "Creating health check..."
cat > /var/www/html/health <<EOF
{
  "status": "healthy",
  "service": "openclaw",
  "environment": "$ENVIRONMENT",
  "agents": $AGENTS_COUNT,
  "timestamp": "$(date -Iseconds)"
}
EOF

# Final status
echo "========================================="
echo "OpenClaw Bootstrap Complete!"
echo "Started: $(date)"
echo ""
echo "Services:"
echo "  - OpenClaw: systemctl status openclaw"
echo "  - Keycloak: docker ps"
echo "  - Nginx: systemctl status nginx"
echo ""
echo "Logs:"
echo "  - Bootstrap: /var/log/openclaw-bootstrap.log"
echo "  - OpenClaw: journalctl -u openclaw -f"
echo ""
echo "Next steps:"
echo "  1. Configure DNS for this VM"
echo "  2. Run: certbot --nginx -d your-domain.com"
echo "  3. Access: https://your-domain.com"
echo "========================================="
