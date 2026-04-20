---
name: vm-deploy
description: SSH to the Azure VM, manage systemd services, deploy config changes, and read logs
modelHint: repetitive
---

# VM Deploy Skill

## Scope
Azure VM at `openclaw-reevelobo.eastus.cloudapp.azure.com` (IP: 13.92.42.136), Ubuntu 22.04, user: `azureuser`.

## Connect
```bash
ssh azureuser@openclaw-reevelobo.eastus.cloudapp.azure.com
# or by IP:
ssh azureuser@13.92.42.136
```

## Service Management
```bash
# Status overview
sudo systemctl status openclaw paperclip oauth2-proxy nginx

# Restart a service
sudo systemctl restart openclaw
sudo systemctl restart paperclip
sudo systemctl restart oauth2-proxy
sudo systemctl reload nginx  # graceful reload for nginx

# View logs (live)
sudo journalctl -u openclaw -f
sudo journalctl -u paperclip -f
sudo journalctl -u oauth2-proxy -f
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## Update a Config File
```bash
# Copy local file to VM (from local machine):
scp openclaw/config.json azureuser@openclaw-reevelobo.eastus.cloudapp.azure.com:~/.openclaw/config.json

# Or via Terraform (preferred for reproducibility):
terraform apply -target=null_resource.openclaw_config
```

## Disk / Process Info
```bash
df -h           # disk usage
free -h         # memory
ps aux | grep -E "openclaw|paperclip"
```

## Service File Locations
- OpenClaw: `/etc/systemd/system/openclaw.service`, data: `~/.openclaw/`
- Paperclip: `/etc/systemd/system/paperclip.service`, data: `~/.paperclip/`
- Nginx: `/etc/nginx/conf.d/openclaw.conf`
- Keycloak: Docker Compose at `~/keycloak/docker-compose.yml`
