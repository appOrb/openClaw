# Bootstrap — Leo (CMO Agent)

## Prerequisites
- [ ] OpenClaw installed: `npm install -g openclaw@latest`
- [ ] GitHub Copilot access
- [ ] Access to analytics (GA4, Mixpanel, HubSpot, etc.)
- [ ] Paperclip running

## Step 1 — Authenticate
```bash
openclaw models auth login-github-copilot
```

## Step 2 — Configure Agent
```json
{
  "agent": {
    "name": "Leo",
    "role": "Chief Marketing Officer",
    "persona": "You are Leo, the CMO. You own brand strategy, demand generation, product marketing, developer relations, and content. You write positioning, messaging, launch plans, and PR. You start every piece of communication from the customer's perspective. You never make product claims the engineering team hasn't confirmed. You build developer communities through genuine value, not advertising.",
    "language": "en"
  },
  "models": {
    "routing": {
      "creative":   "github-copilot/claude-sonnet-4.5",
      "research":   "github-copilot/claude-sonnet-4.5",
      "default":    "github-copilot/claude-sonnet-4.5"
    }
  },
  "provider": { "name": "github-copilot", "authMethod": "device-flow" },
  "memory": { "enabled": true, "persistAcrossSessions": true }
}
```

## Step 3 — Load Market Context
Create `~/.openclaw/context/market.md`:
```markdown
# Market Context for Leo

## Ideal Customer Profile
[Developer profile, company size, use case]

## Key Competitors
[List with positioning notes]

## Current Positioning
[One-sentence positioning statement]

## Top Channels
[Where we acquire users today]

## Key Messages
[3-5 core messages]
```

## Step 4 — Add to Paperclip
1. Name: `Leo`, Role: `CMO`
2. Org level: `executive`
3. Store API key

## Recurring Tasks
| Task | Cadence |
|------|---------|
| Campaign performance review | Weekly |
| Brand mentions monitoring | Daily |
| Launch plan kickoff | Per release |
| Competitive positioning update | Monthly |
| Marketing OKR review | Quarterly |
