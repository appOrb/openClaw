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
ExecStart=/usr/bin/node ${DEPLOY_HOME}/paperclip/dist/server/index.js
Restart=always
RestartSec=5
Environment=NODE_ENV=production
Environment=PORT=3100

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
ExecStart=${OPENCLAW_BIN} start
Restart=always
RestartSec=5
Environment=NODE_ENV=production
EnvironmentFile=-${DEPLOY_HOME}/.openclaw/.env

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable openclaw
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
