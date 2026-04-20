---
name: docker-compose-manage
description: Manage the Keycloak Docker Compose stack on the Azure VM — start, stop, upgrade, inspect logs
modelHint: repetitive
---

# Docker Compose Manage Skill

## Scope
Keycloak runs as Docker Compose on the Azure VM at `~/keycloak/docker-compose.yml`.

## Common Operations
```bash
# Connect to VM first
ssh azureuser@openclaw-reevelobo.eastus.cloudapp.azure.com
cd ~/keycloak/

# Status
docker compose ps

# Logs (live)
docker compose logs -f keycloak

# Restart
docker compose restart keycloak

# Full cycle (stop → pull → start)
docker compose down
docker compose pull
docker compose up -d

# Open a shell inside Keycloak
docker exec -it keycloak bash
```

## Upgrading Keycloak Version
1. Edit `docker-compose.yml` → change `image: quay.io/keycloak/keycloak:XX.Y.Z`
2. Export realm first: `docker exec keycloak /opt/keycloak/bin/kc.sh export --realm openclaw --file /tmp/export.json`
3. `docker cp keycloak:/tmp/export.json ~/keycloak/realm-export.json`
4. `docker compose down && docker compose up -d`
5. Verify at `https://<FQDN>/auth/admin/`

## Health Check
```bash
curl -s http://localhost:8080/auth/health/live | python3 -m json.tool
# Expected: {"status": "UP"}
```

## Volume Location
Keycloak data persists at Docker volume `keycloak_data` — survives container restarts.
