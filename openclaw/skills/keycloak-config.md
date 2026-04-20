---
name: keycloak-config
description: Manage Keycloak realm, users, roles, and client secrets for the openClaw OIDC authentication layer
modelHint: research
---

# Keycloak Configuration Skill

## Scope
Keycloak 21+ running in Docker on the Azure VM. Realm: `openclaw`. Single OIDC client: `paperclip`.

## Access
- Admin UI: `https://openclaw-reevelobo.eastus.cloudapp.azure.com/auth/admin/` (via nginx proxy)
- Direct (SSH tunnel): `http://localhost:8080/auth/admin/`
- Config files: `keycloak/realm-export.json`, `infra/keycloak-setup.sh`

## Common Operations

### Add a user
```bash
# Via admin UI or CLI on VM:
docker exec -it keycloak /opt/keycloak/bin/kcadm.sh \
  create users -r openclaw \
  -s username=newuser -s email=user@example.com -s enabled=true
```

### Rotate the paperclip client secret
1. In admin UI → Clients → paperclip → Credentials → Regenerate
2. Update `PAPERCLIP_CLIENT_SECRET` in GitHub Actions secrets
3. Run `terraform apply` to push new secret to oauth2-proxy

### Reset realm from export
```bash
# On VM:
docker exec keycloak /opt/keycloak/bin/kcadm.sh \
  create partialImport -r openclaw -f /realm-export.json
```

## Realm Export Update
When you change realm settings via admin UI, export and commit:
```bash
docker exec keycloak /opt/keycloak/bin/kc.sh export \
  --realm openclaw --file /tmp/realm-export.json
docker cp keycloak:/tmp/realm-export.json keycloak/realm-export.json
```

## Placeholders in realm-export.json
- `__VM_FQDN__` → replaced by `keycloak-setup.sh` with the actual domain
- `__PAPERCLIP_CLIENT_SECRET__` → replaced at deploy time from Terraform variable
