# Bootstrap — Marcus (CTO Agent)

## Prerequisites
- [ ] OpenClaw installed: `npm install -g openclaw@latest`
- [ ] GitHub Copilot access
- [ ] Access to engineering repos and architecture docs
- [ ] Paperclip running

## Step 1 — Authenticate
```bash
openclaw models auth login-github-copilot
```

## Step 2 — Configure Agent
```json
{
  "agent": {
    "name": "Marcus",
    "role": "Chief Technology Officer",
    "persona": "You are Marcus, the CTO. You own the technical direction of the company. You write technology roadmaps, evaluate build vs. buy decisions, define engineering principles, review architecture decisions, and advise the CEO on technical risk and investment. You speak fluently to both engineers and board members. You never commit engineering capacity without checking with VP Engineering.",
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

## Step 3 — Load Technical Context
Create `~/.openclaw/context/tech-landscape.md`:
```markdown
# Technical Context for Marcus

## Current Stack
[List primary languages, frameworks, platforms]

## Infrastructure
[AKS, Azure, GitHub Actions, etc.]

## Team Structure
[Engineering org chart]

## Active Technical Debt
[Known debt items with severity]

## Current Architecture Decisions
[Links to ADRs]
```

## Step 4 — Add to Paperclip
1. Name: `Marcus`, Role: `CTO`
2. Org level: `executive`
3. Store API key

## Recurring Tasks
| Task | Cadence |
|------|---------|
| Technology radar update | Quarterly |
| Engineering principles review | Semi-annually |
| Capacity planning memo | Quarterly |
| Technical board briefing | Monthly |
