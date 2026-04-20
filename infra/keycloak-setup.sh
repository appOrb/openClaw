#!/usr/bin/env bash
# infra/keycloak-setup.sh — Deploy Keycloak + oauth2-proxy on the Azure VM.
# Called by Terraform's keycloak_setup null_resource after bootstrap.
# Safe to re-run (idempotent).
#
# Required env vars (passed by Terraform, marked sensitive):
#   KC_ADMIN_PASSWORD      — Keycloak admin password (≥8 chars)
#   KC_CLIENT_SECRET       — OIDC client secret for the Paperclip client
#   OAUTH2_COOKIE_SECRET   — Cookie secret for oauth2-proxy (32 bytes, base64-encoded)
#   VM_FQDN                — VM FQDN (e.g. openclaw-yourname.eastus.cloudapp.azure.com)
#   DEPLOY_HOME            — Deploy user home directory (default: /home/azureuser)
#   DEPLOY_USER            — Deploy username (default: azureuser)

set -euo pipefail

DEPLOY_USER="${DEPLOY_USER:-${SUDO_USER:-azureuser}}"
DEPLOY_HOME="${DEPLOY_HOME:-/home/${DEPLOY_USER}}"
export VM_FQDN="${VM_FQDN:-$(curl -sf https://ifconfig.me || hostname -I | awk '{print $1}')}"
export KEYCLOAK_DIR="${KEYCLOAK_DIR:-${DEPLOY_HOME}/keycloak}"
OAUTH2_PROXY_VERSION="v7.6.0"

echo "══════════════════════════════════════════════"
echo "  Keycloak + oauth2-proxy Setup"
echo "══════════════════════════════════════════════"

# ── Docker Engine ──────────────────────────────────────────────────────────────
echo ""
echo "==> Installing Docker Engine"
if ! command -v docker &>/dev/null; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  # shellcheck disable=SC1091
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${VERSION_CODENAME}") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update -qq
  apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin
  systemctl enable docker
  systemctl start docker
fi
echo "    docker: $(docker --version | head -1)"

# ── Keycloak (Identity Provider) ──────────────────────────────────────────────
echo ""
echo "==> Deploying Keycloak"
mkdir -p "${KEYCLOAK_DIR}"

# Write env file (600 permissions — admin password never world-readable)
install -m 600 /dev/null "${KEYCLOAK_DIR}/.env"
printf 'KEYCLOAK_ADMIN=admin\nKEYCLOAK_ADMIN_PASSWORD=%s\n' \
  "${KC_ADMIN_PASSWORD}" > "${KEYCLOAK_DIR}/.env"

# Substitute Paperclip client secret and VM FQDN into realm export using Python
# (safe: secrets are read from env, not embedded in the script string)
python3 - << 'PYEOF'
import os
src = '/tmp/keycloak/realm-export.json'
dst = os.path.join(os.environ['KEYCLOAK_DIR'], 'realm-export.json')
with open(src) as f:
    content = f.read()
content = content.replace('__PAPERCLIP_CLIENT_SECRET__', os.environ['KC_CLIENT_SECRET'])
content = content.replace('__VM_FQDN__', os.environ.get('VM_FQDN', 'localhost'))
with open(dst, 'w') as f:
    f.write(content)
os.chmod(dst, 0o640)
PYEOF

cp /tmp/keycloak/docker-compose.yml "${KEYCLOAK_DIR}/docker-compose.yml"
chown -R "${DEPLOY_USER}:${DEPLOY_USER}" "${KEYCLOAK_DIR}"

# Systemd service for Keycloak
cat > /etc/systemd/system/keycloak.service << UNIT
[Unit]
Description=Keycloak Identity Provider
After=docker.service network.target
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=${KEYCLOAK_DIR}
ExecStartPre=/usr/bin/docker compose pull --quiet
ExecStart=/usr/bin/docker compose up --remove-orphans
ExecStop=/usr/bin/docker compose down
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable keycloak
systemctl restart keycloak
echo "    keycloak.service started ✓"

# ── oauth2-proxy (Authentication Gateway) ─────────────────────────────────────
echo ""
echo "==> Installing oauth2-proxy ${OAUTH2_PROXY_VERSION}"
if ! command -v oauth2-proxy &>/dev/null; then
  curl -fsSL \
    "https://github.com/oauth2-proxy/oauth2-proxy/releases/download/${OAUTH2_PROXY_VERSION}/oauth2-proxy-${OAUTH2_PROXY_VERSION}.linux-amd64.tar.gz" \
    | tar -xz -C /tmp
  install -m 755 \
    "/tmp/oauth2-proxy-${OAUTH2_PROXY_VERSION}.linux-amd64/oauth2-proxy" \
    /usr/local/bin/oauth2-proxy
fi
echo "    oauth2-proxy: $(oauth2-proxy --version 2>/dev/null || echo "${OAUTH2_PROXY_VERSION}")"

# Write oauth2-proxy configuration (secrets injected via env, never hardcoded).
# Detect whether HTTPS (certbot SSL) is already configured so the redirect URL
# and cookie-secure setting match the actual protocol in use.
install -m 600 /dev/null /etc/oauth2-proxy.cfg
export HTTPS_READY=false
if [ -d "/etc/letsencrypt/live/${VM_FQDN}" ]; then
  export HTTPS_READY=true
fi

python3 - << 'PYEOF'
import os
fqdn = os.environ.get('VM_FQDN', '')
https_ready = os.environ.get('HTTPS_READY', 'false') == 'true'
scheme = 'https' if https_ready else 'http'
# cookie-secure requires HTTPS; it is set to true automatically once certbot has run
cfg = (
    'provider = "keycloak-oidc"\n'
    'client-id = "paperclip"\n'
    'client-secret = "{client_secret}"\n'
    'redirect-url = "{scheme}://{fqdn}/oauth2/callback"\n'
    'oidc-issuer-url = "http://localhost:8080/realms/openclaw"\n'
    'upstreams = ["http://127.0.0.1:3100/"]\n'
    'email-domains = ["*"]\n'
    'cookie-secret = "{cookie_secret}"\n'
    'http-address = "0.0.0.0:4180"\n'
    'cookie-secure = {cookie_secure}\n'
    'reverse-proxy = true\n'
    'skip-provider-button = true\n'
    'pass-access-token = true\n'
    'pass-authorization-header = true\n'
    'set-xauthrequest = true\n'
).format(
    client_secret=os.environ['KC_CLIENT_SECRET'],
    fqdn=fqdn,
    scheme=scheme,
    cookie_secret=os.environ['OAUTH2_COOKIE_SECRET'],
    cookie_secure=str(https_ready).lower(),
)
with open('/etc/oauth2-proxy.cfg', 'w') as f:
    f.write(cfg)
os.chmod('/etc/oauth2-proxy.cfg', 0o600)
PYEOF

# Systemd service for oauth2-proxy
cat > /etc/systemd/system/oauth2-proxy.service << UNIT
[Unit]
Description=oauth2-proxy Authentication Gateway for Paperclip
After=keycloak.service network.target
Wants=keycloak.service

[Service]
Type=simple
User=${DEPLOY_USER}
ExecStart=/usr/local/bin/oauth2-proxy --config=/etc/oauth2-proxy.cfg
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable oauth2-proxy
systemctl restart oauth2-proxy
echo "    oauth2-proxy.service started ✓"

echo ""
echo "══════════════════════════════════════════════"
echo "  Keycloak + oauth2-proxy setup complete!"
echo "══════════════════════════════════════════════"
echo ""
echo "  Traffic flow: Browser → Nginx → oauth2-proxy (4180) → Paperclip (3100)"
echo "  Keycloak admin (SSH tunnel only, port 8080 is NOT exposed externally):"
echo "    ssh -L 8080:localhost:8080 ${DEPLOY_USER}@${VM_FQDN}"
echo "    Then open: http://localhost:8080/admin"
echo ""
echo "  ⚠️  After enabling HTTPS (certbot), set cookie-secure = true in"
echo "     /etc/oauth2-proxy.cfg and restart: sudo systemctl restart oauth2-proxy"
echo ""
