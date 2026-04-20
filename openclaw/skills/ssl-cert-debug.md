---
name: ssl-cert-debug
description: Diagnose and renew Let's Encrypt SSL certificates on the openClaw nginx server
modelHint: debug
---

# SSL Certificate Debug Skill

## Scope
Let's Encrypt certificates via Certbot on the Azure VM. Nginx terminates TLS.

## Check Certificate Status
```bash
# On VM:
sudo certbot certificates
# Shows: expiry date, domains, certificate path

# Check expiry via curl:
echo | openssl s_client -connect openclaw-reevelobo.eastus.cloudapp.azure.com:443 2>/dev/null \
  | openssl x509 -noout -dates
```

## Manual Renewal
```bash
sudo certbot renew --dry-run   # test first
sudo certbot renew             # actual renewal
sudo systemctl reload nginx    # activate new cert
```

## Auto-Renewal (should already be configured)
```bash
systemctl list-timers | grep certbot
# Should show a certbot.timer running periodically
```

## Certbot Fails — Common Causes
1. **Port 80 blocked** — NSG must allow inbound TCP 80 for ACME challenge
   - Check Azure Portal → NSG → Inbound Security Rules
2. **nginx not serving .well-known** — verify nginx config has:
   ```nginx
   location /.well-known/acme-challenge/ {
       root /var/www/certbot;
   }
   ```
3. **Rate limited** — Let's Encrypt allows 5 renewals per week per domain; use `--staging` to test

## Certificate Paths
```
/etc/letsencrypt/live/openclaw-reevelobo.eastus.cloudapp.azure.com/fullchain.pem
/etc/letsencrypt/live/openclaw-reevelobo.eastus.cloudapp.azure.com/privkey.pem
```
