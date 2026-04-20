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

systemctl restart openclaw || echo "    openclaw will start after: openclaw models auth login-github-copilot"
echo "    openclaw.service enabled ✓"

# ── Nginx ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> Enabling Nginx"
systemctl enable nginx
systemctl start nginx
echo "    nginx started ✓"

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
echo "Next steps:"
echo "  1. Authenticate GitHub Copilot:"
echo "       openclaw models auth login-github-copilot"
echo "  2. Deploy OpenClaw config:"
echo "       (run from your local machine)"
echo "       scp openclaw/config.json azureuser@VM_IP:~/.openclaw/openclaw.json"
echo "       scp -r openclaw/skills/ azureuser@VM_IP:~/.openclaw/skills/"
echo "  3. Set up Nginx + SSL (see README)"
echo ""
