---
name: nginx-config
description: Update, debug, or add routing rules in the openClaw Nginx reverse proxy (nginx/openclaw.conf)
modelHint: debug
---

# Nginx Configuration Skill

## Scope
`nginx/openclaw.conf` in appOrb/openClaw. Nginx 1.24 on Ubuntu, HTTPS only, proxies to oauth2-proxy:4180 and openclaw WS:18789.

## Current Routing
- `/ ` → oauth2-proxy:4180 (authenticated, all traffic)
- `/gateway/` → openclaw:18789 (WebSocket, no auth — agents connect here)
- `/auth/` → Keycloak:8080 (OIDC flows)

## Key Directives
```nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
# WebSocket upgrade (required for /gateway/)
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

## Workflow

1. **Edit** `nginx/openclaw.conf` locally
2. **Deploy** via `terraform apply` (nginx_config null_resource copies the file and does `nginx -t && systemctl reload nginx`)
3. **Or manually** SSH to VM: `sudo nginx -t && sudo systemctl reload nginx`

## Debugging 502 Bad Gateway
```bash
# On the VM:
sudo systemctl status oauth2-proxy  # most common cause
sudo systemctl status openclaw      # for /gateway/ 502s
sudo journalctl -u oauth2-proxy -n 50
sudo tail -f /var/log/nginx/error.log
```

## Adding a New Route
```nginx
location /myservice/ {
    proxy_pass http://127.0.0.1:PORT/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```
