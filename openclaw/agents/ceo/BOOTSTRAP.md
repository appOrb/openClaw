# Bootstrap — Diana (CEO Agent)

## Prerequisites
- [ ] OpenClaw installed: `npm install -g openclaw@latest`
- [ ] GitHub Copilot access
- [ ] Paperclip running with org structure configured
- [ ] Company OKR document and strategic context available

## Step 1 — Authenticate
```bash
openclaw models auth login-github-copilot
```

## Step 2 — Configure Agent
Create `~/.openclaw/openclaw.json`:
```json
{
  "agent": {
    "name": "Diana",
    "role": "Chief Executive Officer",
    "persona": "You are Diana, the CEO of OpenClaw. You set company vision, define strategy, own OKRs, manage the executive team, and communicate with the board and investors. You write with clarity and conviction. You make decisions with incomplete information. You always consider the long-term health of the company over short-term metrics. You never make financial or legal commitments without CFO or legal review.",
    "language": "en"
  },
  "models": {
    "routing": {
      "research":   "github-copilot/claude-sonnet-4.5",
      "creative":   "github-copilot/claude-sonnet-4.5",
      "logic":      "github-copilot/claude-sonnet-4.5",
      "default":    "github-copilot/claude-sonnet-4.5"
    }
  },
  "provider": { "name": "github-copilot", "authMethod": "device-flow" },
  "memory": { "enabled": true, "persistAcrossSessions": true }
}
```

## Step 3 — Load Company Context
Diana requires context to be effective. Create `~/.openclaw/context/company.md`:
```markdown
# Company Context for Diana

## Mission
[Your company mission]

## Current Stage
[Seed / Series A / etc.]

## Key Metrics
- ARR: $X
- Headcount: X
- Runway: X months

## Current OKRs
[Paste current OKRs]

## Board Members
[List names and firms]
```

## Step 4 — Add to Paperclip
1. Log in to Paperclip
2. **Agents** → **Add Agent**
3. Name: `Diana`, Role: `CEO`
4. Set org level: `executive`
5. Store key: `echo "OPENCLAW_AGENT_KEY=<key>" >> ~/.openclaw/.env`

## Step 5 — Start Gateway
```bash
systemctl start openclaw
```

## Recurring Tasks Diana Handles
| Task | Cadence |
|------|---------|
| Weekly executive team summary | Weekly |
| Board update draft | Monthly |
| OKR review memo | Quarterly |
| Company all-hands talking points | Quarterly |
| Annual strategic plan | Annually |
