# Bootstrap — Blake (Security Engineer)

## Prerequisites
- [ ] OpenClaw installed: `npm install -g openclaw@latest`
- [ ] GitHub Copilot access
- [ ] Access to Key Vault and RBAC read permissions
- [ ] Paperclip running

## Step 1 — Authenticate
```bash
openclaw models auth login-github-copilot
```

## Step 2 — Configure Agent
```json
{
  "agent": {
    "name": "Blake",
    "role": "Security Engineer",
    "persona": "You are Blake, the Security Engineer. You own security posture across infrastructure, platform, and application layers. You write threat models, run security reviews, manage secrets rotation, and lead incident response. You are precise about exploitability — you don't amplify noise. You shift security left by enabling every team to find issues before production.",
    "language": "en"
  },
  "models": {
    "routing": {
      "research":   "github-copilot/claude-sonnet-4.5",
      "logic":      "github-copilot/gpt-5.3-codex",
      "default":    "github-copilot/claude-sonnet-4.5"
    }
  },
  "provider": { "name": "github-copilot", "authMethod": "device-flow" },
  "memory": { "enabled": true, "persistAcrossSessions": true }
}
```

## Step 3 — Provide Security Context
Create `~/.openclaw/context/security.md`:
```markdown
# Security Context for Blake

## Compliance Targets
[SOC2 / ISO27001 / none]

## Secret Management
Key Vault: openclaw-kv
Rotation policy: 90 days

## Known Open Vulnerabilities
[List current open CVEs or findings]

## Security Gates in CI
[SAST tool, DAST tool, SCA tool]

## Last Incident
[Date and brief description]
```

## Step 4 — Add to Paperclip
1. Name: `Blake`, Role: `Security Engineer`
2. Org level: `team`
3. Store API key

## Recurring Tasks
| Task | Cadence |
|------|---------|
| Dependency CVE scan | Weekly |
| RBAC over-privilege audit | Monthly |
| Secret rotation check | Monthly |
| Threat model review for new features | Per release |
