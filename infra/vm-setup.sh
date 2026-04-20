#!/usr/bin/env bash
# infra/vm-setup.sh — Bootstrap OpenClaw + Paperclip on the Azure VM
# Run on the VM via: ssh azureuser@VM_IP 'bash -s' < infra/vm-setup.sh
# Takes ~5 minutes. Safe to re-run (idempotent).

set -euo pipefail

DEPLOY_USER="${SUDO_USER:-azureuser}"
DEPLOY_HOME="/home/${DEPLOY_USER}"

echo "══════════════════════════════════════════════"
echo "  OpenClaw VM Bootstrap"
echo "══════════════════════════════════════════════"

# ── System packages ────────────────────────────────────────────────────────────
echo ""
echo "==> Installing system packages"
sudo apt-get update -qq
sudo apt-get install -y -qq \
  git curl wget gnupg ca-certificates \
  nginx certbot python3-certbot-nginx \
  build-essential

# ── Node.js 22 ────────────────────────────────────────────────────────────────
if ! node --version 2>/dev/null | grep -q "^v22"; then
  echo "==> Installing Node.js 22"
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y -qq nodejs
fi
echo "    Node: $(node --version)  npm: $(npm --version)"

# ── pnpm ──────────────────────────────────────────────────────────────────────
if ! command -v pnpm &>/dev/null; then
  echo "==> Installing pnpm"
  npm install -g pnpm --quiet
fi
echo "    pnpm: $(pnpm --version)"

# ── OpenClaw ──────────────────────────────────────────────────────────────────
echo ""
echo "==> Installing OpenClaw"
npm install -g openclaw@latest --quiet
echo "    openclaw: $(openclaw --version 2>/dev/null || echo 'installed')"

mkdir -p "${DEPLOY_HOME}/.openclaw/skills"
chown -R "${DEPLOY_USER}:${DEPLOY_USER}" "${DEPLOY_HOME}/.openclaw"

# ── Paperclip ─────────────────────────────────────────────────────────────────
echo ""
echo "==> Installing Paperclip"
PAPERCLIP_DIR="${DEPLOY_HOME}/paperclip"
if [ ! -d "${PAPERCLIP_DIR}" ]; then
  sudo -u "${DEPLOY_USER}" git clone https://github.com/paperclipai/paperclip.git "${PAPERCLIP_DIR}" --quiet
fi
cd "${PAPERCLIP_DIR}"
sudo -u "${DEPLOY_USER}" git pull --quiet
sudo -u "${DEPLOY_USER}" pnpm install --silent
sudo -u "${DEPLOY_USER}" pnpm build
echo "    Paperclip built ✓"
cd ~

# ── Systemd: Paperclip ────────────────────────────────────────────────────────
echo ""
echo "==> Creating systemd service: paperclip"
cat > /etc/systemd/system/paperclip.service << UNIT
[Unit]
Description=Paperclip AI Company Control Plane
After=network.target

[Service]
Type=simple
User=${DEPLOY_USER}
WorkingDirectory=${DEPLOY_HOME}/paperclip
ExecStart=/usr/bin/node --import ./server/node_modules/tsx/dist/loader.mjs server/dist/index.js
Restart=always
RestartSec=5
Environment=NODE_ENV=production
Environment=PORT=3100
Environment=PAPERCLIP_MIGRATION_PROMPT=never
Environment=PAPERCLIP_MIGRATION_AUTO_APPLY=true
Environment="PAPERCLIP_ALLOWED_HOSTNAMES=13.92.42.136,openclaw-reevelobo.eastus.cloudapp.azure.com,localhost,127.0.0.1"

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable paperclip
systemctl restart paperclip
echo "    paperclip.service started ✓"

# ── Systemd: OpenClaw ─────────────────────────────────────────────────────────
echo ""
echo "==> Creating systemd service: openclaw"
OPENCLAW_BIN="$(which openclaw 2>/dev/null || echo '/usr/local/bin/openclaw')"
cat > /etc/systemd/system/openclaw.service << UNIT
[Unit]
Description=OpenClaw AI Developer Employee (Alex)
After=network.target

[Service]
Type=simple
User=${DEPLOY_USER}
WorkingDirectory=${DEPLOY_HOME}
ExecStart=${OPENCLAW_BIN} gateway
Restart=always
RestartSec=5
Environment=NODE_ENV=production
EnvironmentFile=-${DEPLOY_HOME}/.openclaw/.env

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable openclaw

# Pre-configure openclaw gateway settings so it starts without the interactive wizard
sudo -u "${DEPLOY_USER}" bash -c "
  mkdir -p '${DEPLOY_HOME}/.openclaw'
  CONFIG='${DEPLOY_HOME}/.openclaw/openclaw.json'
  if [ ! -f \"\$CONFIG\" ] || ! python3 -c \"import json; d=json.load(open('\$CONFIG')); exit(0 if 'gateway' in d else 1)\" 2>/dev/null; then
    python3 - << 'PYEOF'
import json, os
config_path = os.path.expanduser('${DEPLOY_HOME}/.openclaw/openclaw.json')
try:
    with open(config_path) as f:
        cfg = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    cfg = {}
cfg.setdefault('models', {})
cfg.setdefault('skills', {})
cfg.setdefault('memory', {})
cfg['gateway'] = {'mode': 'local', 'auth': {'mode': 'none'}}
os.makedirs(os.path.dirname(config_path), exist_ok=True)
with open(config_path, 'w') as f:
    json.dump(cfg, f, indent=2)
print('openclaw config seeded with gateway.mode=local')
PYEOF
  fi
"

systemctl restart openclaw || true
echo "    openclaw.service enabled ✓"

# ── GitHub Copilot Auth ───────────────────────────────────────────────────────
# If COPILOT_PAT is set (classic PAT with 'copilot' scope), write auth-profiles.json
# automatically. Otherwise the file is written as a template for manual completion.
echo ""
echo "==> Configuring GitHub Copilot auth"
COPILOT_PAT="${COPILOT_PAT:-}"
AUTH_FILE="${DEPLOY_HOME}/.openclaw/auth-profiles.json"

sudo -u "${DEPLOY_USER}" bash -c "
  cat > '${AUTH_FILE}' << 'AUTHEOF'
{
  \"version\": 1,
  \"profiles\": {
    \"github-copilot:manual\": {
      \"type\": \"token\",
      \"provider\": \"github-copilot\",
      \"token\": \"${COPILOT_PAT}\"
    }
  }
}
AUTHEOF
  echo '    auth-profiles.json written'
"

# ── OpenClaw model configuration ─────────────────────────────────────────────
echo ""
echo "==> Configuring OpenClaw models"
sudo -u "${DEPLOY_USER}" python3 - << 'PYEOF'
import json, os

config_path = os.path.expanduser('~/.openclaw/openclaw.json')
try:
    with open(config_path) as f:
        cfg = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    cfg = {}

# Model routing strategy:
# - Haiku 4.5: repetitive/monotonous tasks (boilerplate, formatting, renaming)
# - Sonnet 4.5: research, architecture, creative thinking
# - gpt-4o: troubleshooting, debugging, logic
cfg['models'] = {
    "default": "github-copilot/gpt-4o",
    "profiles": {
        "repetitive": "github-copilot/claude-haiku-4.5",
        "research": "github-copilot/claude-sonnet-4.5",
        "debug": "github-copilot/gpt-4o"
    }
}

with open(config_path, 'w') as f:
    json.dump(cfg, f, indent=2)
print('    openclaw models configured ✓')
PYEOF

systemctl restart openclaw
echo "    openclaw restarted with model config ✓"

# ── Nginx ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> Enabling Nginx"
systemctl enable nginx
systemctl start nginx || systemctl reload nginx
echo "    nginx started ✓"

# ── SSL via Let's Encrypt ─────────────────────────────────────────────────────
VM_FQDN="${VM_FQDN:-}"
if [ -n "${VM_FQDN}" ]; then
  echo ""
  echo "==> Setting up SSL for ${VM_FQDN}"
  certbot --nginx \
    -d "${VM_FQDN}" \
    --non-interactive \
    --agree-tos \
    -m "admin@openclaw.dev" \
    --redirect 2>&1 | tail -5
  echo "    SSL configured ✓"
else
  echo ""
  echo "==> Skipping SSL (VM_FQDN not set)"
  echo "    Run manually: certbot --nginx -d <your-fqdn> --non-interactive --agree-tos -m admin@openclaw.dev"
fi

# ── Status summary ────────────────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════"
echo "  Bootstrap complete!"
echo "══════════════════════════════════════════════"
echo ""
echo "Services:"
systemctl is-active paperclip openclaw nginx | paste - - - | \
  awk '{print "  paperclip: "$1"  openclaw: "$2"  nginx: "$3}'
echo ""
if [ -z "${COPILOT_PAT}" ]; then
  echo "⚠️  Copilot auth incomplete — set COPILOT_PAT before re-running."
  echo "   1. Create a classic GitHub PAT with 'copilot' scope:"
  echo "      https://github.com/settings/tokens/new?scopes=copilot"
  echo "   2. Re-run this script with COPILOT_PAT=ghp_... or:"
  echo "      ssh azureuser@VM openclaw models auth login-github-copilot"
else
  echo "✅ Copilot auth configured via auth-profiles.json"
fi
echo ""
echo "Dashboard: https://${VM_FQDN:-$(curl -s ifconfig.me)}"
echo ""
