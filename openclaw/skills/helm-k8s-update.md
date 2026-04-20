---
name: helm-k8s-update
description: Update Kubernetes Helm charts and environment overlays in ai_waiter.infrastructure
modelHint: research
---

# Helm / Kubernetes Update Skill

## Repo: `appOrb/ai_waiter.infrastructure`
Structure: `k8s/charts/` (Helm chart definitions), `k8s/environments/` (env-specific overlays), `terraform/` (infra).

## Chart Structure
```
k8s/charts/ai-waiter/
  Chart.yaml
  values.yaml          ← defaults
  templates/
    deployment.yaml
    service.yaml
    ingress.yaml
    configmap.yaml
    hpa.yaml
```

## Update Image Version
```yaml
# values.yaml
image:
  repository: <acr>.azurecr.io/ai-waiter-backend
  tag: "1.2.3"   ← bump this
  pullPolicy: IfNotPresent
```

## Environment Overlay Pattern
```
k8s/environments/
  dev/values.yaml      ← overrides for dev (lower replicas, debug logging)
  staging/values.yaml
  prod/values.yaml     ← prod replicas, resource limits, HPA config
```

## Deploy Commands
```bash
# Install/upgrade
helm upgrade --install ai-waiter k8s/charts/ai-waiter \
  -f k8s/environments/prod/values.yaml \
  --namespace ai-waiter --create-namespace

# Diff before applying (requires helm-diff plugin)
helm diff upgrade ai-waiter k8s/charts/ai-waiter \
  -f k8s/environments/prod/values.yaml

# Rollback
helm rollback ai-waiter 1  # roll back to revision 1
```

## Adding a New Service
1. Create `k8s/charts/<service-name>/` with standard templates
2. Add to `k8s/environments/*/values.yaml` for each env
3. Update `terraform/main.tf` if a new Terraform helm_release block is needed

## Resource Limits Template
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```
