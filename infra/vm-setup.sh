#!/usr/bin/env bash
# infra/vm-setup.sh — Bootstrap OpenClaw + Paperclip on the Azure VM
# Run on the VM via: ssh azureuser@VM_IP 'bash -s' < infra/vm-setup.sh
# Takes ~5 minutes. Safe to re-run (idempotent).

set -euo pipefail

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
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - -qq
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

mkdir -p ~/.openclaw/skills

# ── Paperclip ─────────────────────────────────────────────────────────────────
echo ""
echo "==> Installing Paperclip"
if [ ! -d ~/paperclip ]; then
  git clone https://github.com/paperclipai/paperclip.git ~/paperclip --quiet
fi
cd ~/paperclip
git pull --quiet
pnpm install --silent
pnpm build --silent
echo "    Paperclip built ✓"
cd ~

# ── Systemd: Paperclip ────────────────────────────────────────────────────────
echo ""
echo "==> Creating systemd service: paperclip"
sudo tee /etc/systemd/system/paperclip.service > /dev/null << 'UNIT'
[Unit]
Description=Paperclip AI Company Control Plane
After=network.target

[Service]
Type=simple
User=azureuser
WorkingDirectory=/home/azureuser/paperclip
ExecStart=/usr/bin/node dist/server/index.js
Restart=always
RestartSec=5
Environment=NODE_ENV=production
Environment=PORT=3100

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable paperclip
sudo systemctl restart paperclip
echo "    paperclip.service started ✓"

# ── Systemd: OpenClaw ─────────────────────────────────────────────────────────
echo ""
echo "==> Creating systemd service: openclaw"
sudo tee /etc/systemd/system/openclaw.service > /dev/null << 'UNIT'
[Unit]
Description=OpenClaw AI Developer Employee (Alex)
After=network.target

[Service]
Type=simple
User=azureuser
WorkingDirectory=/home/azureuser
ExecStart=/usr/bin/openclaw start --daemon-mode
Restart=always
RestartSec=5
Environment=NODE_ENV=production
# Secrets file written by Terraform (not in source control)
# Contains: GITHUB_TOKEN=<token>
EnvironmentFile=-/home/azureuser/.openclaw/.env

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable openclaw
sudo systemctl restart openclaw
echo "    openclaw.service started ✓"

# ── Nginx ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> Enabling Nginx"
sudo systemctl enable nginx
sudo systemctl start nginx
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
