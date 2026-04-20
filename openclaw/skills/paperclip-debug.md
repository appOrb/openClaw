---
name: paperclip-debug
description: Diagnose Paperclip agent offline/idle issues, WebSocket gateway failures, and heartbeat problems
modelHint: debug
---

# Paperclip Debug Skill

## Scope
Paperclip running as systemd service on Azure VM at port 3100. OpenClaw WebSocket gateway at port 18789.

## Agent Status Triage
```bash
# 1. Check services running
sudo systemctl status paperclip openclaw

# 2. Paperclip logs
sudo journalctl -u paperclip -n 100 --no-pager

# 3. OpenClaw logs
sudo journalctl -u openclaw -n 100 --no-pager

# 4. Test gateway WebSocket reachability
curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" \
  -H "Host: openclaw-reevelobo.eastus.cloudapp.azure.com" \
  https://openclaw-reevelobo.eastus.cloudapp.azure.com/gateway/
```

## Agent Shows "Offline"
- Paperclip heartbeat fails → OpenClaw not responding on port 18789
- `sudo systemctl restart openclaw` then wait 30s for heartbeat

## Agent Shows "Idle" but Never Responds
- GitHub Copilot PAT expired or missing `copilot` scope
- Check `~/.openclaw/auth-profiles.json` on VM — token field must be a classic PAT
- Regenerate at: https://github.com/settings/tokens → classic → copilot scope
- Update token: `sudo nano ~/.openclaw/auth-profiles.json && sudo systemctl restart openclaw`

## WebSocket 403 / Connection Refused
- Nginx `/gateway/` location missing WebSocket upgrade headers — see nginx-config skill
- Verify: `proxy_http_version 1.1;` and `proxy_set_header Upgrade $http_upgrade;` present

## Config Files
- OpenClaw config: `~/.openclaw/config.json`
- OpenClaw auth: `~/.openclaw/auth-profiles.json`
- Paperclip config: `~/.paperclip/` (company.yaml synced here by Terraform)
