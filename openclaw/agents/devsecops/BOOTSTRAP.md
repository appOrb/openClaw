# Bootstrap — Sam (DevSecOps Agent)

## Prerequisites
- [ ] OpenClaw installed: `npm install -g openclaw@latest`
- [ ] GitHub Copilot access
- [ ] GitHub PAT with scopes: `repo`, `workflow`, `write:packages`, `read:org`
- [ ] Azure CLI authenticated
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
    "name": "Sam",
    "role": "DevSecOps Engineer",
    "persona": "You are Sam, the DevSecOps Engineer. You design, build, and maintain CI/CD pipelines with security embedded at every stage. You run SAST, DAST, container scanning, and secrets detection automatically. You never disable security gates. You make shipping safe and fast at the same time.",
    "language": "en"
  },
  "models": {
    "routing": {
      "repetitive": "github-copilot/claude-haiku-4.5",
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

## Step 3 — Required Tools on Host
```bash
# Install trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin

# Install cosign
COSIGN_VERSION=$(curl -s https://api.github.com/repos/sigstore/cosign/releases/latest | jq -r .tag_name)
curl -LO "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
sudo mv cosign-linux-amd64 /usr/local/bin/cosign && sudo chmod +x /usr/local/bin/cosign

# Install checkov
pip install checkov
```

## Step 4 — Add to Paperclip
1. Log in to Paperclip
2. **Agents** → **Add Agent**
3. Name: `Sam`, Role: `devsecops`
4. Store key:
   ```bash
   echo "OPENCLAW_AGENT_KEY=<key>" >> ~/.openclaw/.env
   ```

## Step 5 — Configure GitHub Secrets
For each repository Sam manages, add:
```
AZURE_CREDENTIALS       ← JSON service principal
ACR_REGISTRY            ← Azure Container Registry URL
COSIGN_PRIVATE_KEY      ← Image signing key
COSIGN_PASSWORD         ← Key passphrase
```

## Step 6 — Start Gateway
```bash
systemctl start openclaw
```

## Recurring Maintenance
| Task | Frequency |
|------|-----------|
| Review Dependabot alerts | Daily |
| Rotate signing keys | Every 180 days |
| Audit pipeline permissions | Monthly |
| Update scanner versions | Monthly |
