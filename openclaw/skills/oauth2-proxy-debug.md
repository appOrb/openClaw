---
name: oauth2-proxy-debug
description: Diagnose and fix oauth2-proxy errors including CSRF failures, 500 on /oauth2/callback, and cookie issues
modelHint: debug
---

# oauth2-proxy Debug Skill

## Scope
oauth2-proxy v7.x running as systemd service on the Azure VM, proxying Keycloak OIDC for the `paperclip` client.

## Most Common Errors

### 500 Internal Server Error on /oauth2/callback
**Cause**: oauth2-proxy cannot reach Keycloak internally, or the redirect URI registered in Keycloak doesn't match.

**Check**:
```bash
sudo journalctl -u oauth2-proxy -n 100 --no-pager
# Look for: "failed to redeem code" or "error redeeming code"
```

**Fix**: Ensure `--oidc-issuer-url` matches exactly what Keycloak returns in `/.well-known/openid-configuration`. Must use the PUBLIC URL, not localhost.

### 403 CSRF Token Error
**Cause**: The CSRF cookie (`_oauth2_proxy_csrf`) is set for a different domain/path than the callback receives.

**Fix**:
```bash
# Check cookie domain in oauth2-proxy config:
--cookie-domain=openclaw-reevelobo.eastus.cloudapp.azure.com
--whitelist-domain=openclaw-reevelobo.eastus.cloudapp.azure.com
# If using SameSite=None, cookie-secure must be true (HTTPS only)
```

### 502 Bad Gateway on /oauth2/callback
**Cause**: oauth2-proxy service is down.
```bash
sudo systemctl status oauth2-proxy
sudo systemctl restart oauth2-proxy
```

## Key Config Variables (in /etc/oauth2-proxy.conf or systemd env)
```
OAUTH2_PROXY_CLIENT_ID=paperclip
OAUTH2_PROXY_CLIENT_SECRET=<keycloak client secret>
OAUTH2_PROXY_OIDC_ISSUER_URL=https://<FQDN>/auth/realms/openclaw
OAUTH2_PROXY_REDIRECT_URL=https://<FQDN>/oauth2/callback
OAUTH2_PROXY_COOKIE_SECRET=<32-byte base64 secret>
OAUTH2_PROXY_EMAIL_DOMAINS=*
OAUTH2_PROXY_UPSTREAM=http://127.0.0.1:3100
```

## Re-generate Cookie Secret
```bash
python3 -c "import secrets,base64; print(base64.b64encode(secrets.token_bytes(32)).decode())"
```
Update in `/etc/oauth2-proxy.conf` and `sudo systemctl restart oauth2-proxy`.
