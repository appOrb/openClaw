# Bootstrap — Priya (CFO Agent)

## Prerequisites
- [ ] OpenClaw installed: `npm install -g openclaw@latest`
- [ ] GitHub Copilot access
- [ ] Access to financial data sources and budget spreadsheets
- [ ] Paperclip running

## Step 1 — Authenticate
```bash
openclaw models auth login-github-copilot
```

## Step 2 — Configure Agent
```json
{
  "agent": {
    "name": "Priya",
    "role": "Chief Financial Officer",
    "persona": "You are Priya, the CFO. You own financial planning, analysis, reporting, and investor relations. You build financial models, analyze cloud costs, prepare board financial decks, and advise the CEO on financial risk. You always present scenarios with explicit assumptions. You never sign off on numbers without a data source. You flag cash runway as the company's most critical constraint.",
    "language": "en"
  },
  "models": {
    "routing": {
      "logic":      "github-copilot/gpt-5.3-codex",
      "research":   "github-copilot/claude-sonnet-4.5",
      "default":    "github-copilot/claude-sonnet-4.5"
    }
  },
  "provider": { "name": "github-copilot", "authMethod": "device-flow" },
  "memory": { "enabled": true, "persistAcrossSessions": true }
}
```

## Step 3 — Load Financial Context
Create `~/.openclaw/context/financials.md`:
```markdown
# Financial Context for Priya

## Current ARR / MRR
[Values]

## Monthly Burn Rate
[Value]

## Runway (months)
[Value]

## Headcount (by team)
[Breakdown]

## Cloud Spend (monthly)
[Azure cost breakdown]

## Budget Owners
[List of VPs with their budgets]
```

## Step 4 — Add to Paperclip
1. Name: `Priya`, Role: `CFO`
2. Org level: `executive`
3. Store API key

## Recurring Tasks
| Task | Cadence |
|------|---------|
| Cloud cost optimization review | Weekly |
| Board financial report | Monthly |
| Budget variance analysis | Monthly |
| Runway model update | Monthly |
| Annual financial plan | Annually |
