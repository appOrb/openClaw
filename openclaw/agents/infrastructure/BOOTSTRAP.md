# Bootstrap — Sage (Infrastructure Engineer)

## Prerequisites
- [ ] OpenClaw installed: `npm install -g openclaw@latest`
- [ ] Azure CLI installed and logged in: `az login`
- [ ] Terraform ≥ 1.5 installed
- [ ] Paperclip running

## Step 1 — Authenticate
```bash
openclaw models auth login-github-copilot
```

## Step 2 — Configure Agent
```json
{
  "agent": {
    "name": "Sage",
    "role": "Infrastructure Engineer",
    "persona": "You are Sage, the Infrastructure Engineer. You provision and maintain all Azure infrastructure using Terraform. You write IaC, manage persistent disks, configure networking, and track cloud costs. You never apply destructive plans without explicit review. You always estimate cost before provisioning. You use prevent_destroy on critical resources by default.",
    "language": "en"
  },
  "models": {
    "routing": {
      "repetitive": "github-copilot/claude-haiku-4.5",
      "logic":      "github-copilot/gpt-5.3-codex",
      "default":    "github-copilot/claude-sonnet-4.5"
    }
  },
  "provider": { "name": "github-copilot", "authMethod": "device-flow" },
  "memory": { "enabled": true, "persistAcrossSessions": true }
}
```

## Step 3 — Provide Infra Context
Create `~/.openclaw/context/infra.md`:
```markdown
# Infra Context for Sage

## Azure Subscription
[Subscription ID]

## Resource Group
openclaw-rg

## VM
Name: openclaw-vm
SKU: Standard_B2s
Region: eastus

## Persistent Disk
LUN: 10
Size: 32GB
Mount: /mnt/openclaw-data

## Terraform State
Backend: azurerm (storage account)
Container: tfstate
Key: openclaw.tfstate
```

## Step 4 — Add to Paperclip
1. Name: `Sage`, Role: `Infrastructure Engineer`
2. Org level: `team`
3. Store API key

## Recurring Tasks
| Task | Cadence |
|------|---------|
| Cost review | Weekly |
| Disk utilization check | Weekly |
| Terraform drift detection | Daily |
| Backup verification | Monthly |
