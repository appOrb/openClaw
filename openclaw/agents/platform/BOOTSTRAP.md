# Bootstrap — Jordan (Platform Agent)

## Prerequisites
- [ ] OpenClaw installed: `npm install -g openclaw@latest`
- [ ] GitHub Copilot access
- [ ] `kubectl` configured against target cluster
- [ ] Helm 3.x installed
- [ ] ArgoCD CLI installed
- [ ] Paperclip running

## Step 1 — Authenticate GitHub Copilot
```bash
openclaw models auth login-github-copilot
```

## Step 2 — Configure Agent
Create `~/.openclaw/openclaw.json`:
```json
{
  "agent": {
    "name": "Jordan",
    "role": "Platform Engineer",
    "persona": "You are Jordan, the Platform Engineer. You build and maintain the internal developer platform. You create golden paths, shared tooling, observability stacks, and developer experience improvements. You make shipping and operating software easier for every team. You treat developer experience as a product.",
    "language": "en"
  },
  "models": {
    "routing": {
      "repetitive": "github-copilot/claude-haiku-4.5",
      "research":   "github-copilot/claude-sonnet-4.5",
      "logic":      "github-copilot/gpt-5.3-codex",
      "default":    "github-copilot/claude-sonnet-4.5"
    }
  },
  "provider": {
    "name": "github-copilot",
    "authMethod": "device-flow"
  },
  "memory": {
    "enabled": true,
    "persistAcrossSessions": true
  }
}
```

## Step 3 — Verify Platform Access
```bash
# Cluster access
kubectl get nodes

# ArgoCD access
argocd cluster list

# Helm repos
helm repo list
```

## Step 4 — Add Core Helm Repos
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add jetstack https://charts.jetstack.io
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

## Step 5 — Add to Paperclip
1. Log in to Paperclip
2. **Agents** → **Add Agent**
3. Name: `Jordan`, Role: `platform`
4. Store key:
   ```bash
   echo "OPENCLAW_AGENT_KEY=<key>" >> ~/.openclaw/.env
   ```

## Step 6 — Start Gateway
```bash
systemctl start openclaw
```

## Recurring Maintenance
| Task | Frequency |
|------|-----------|
| Check cluster add-on health | Daily |
| Review Grafana alert backlog | Daily |
| Helm chart dependency updates | Weekly |
| Developer satisfaction survey | Monthly |
| Platform toil measurement | Quarterly |
