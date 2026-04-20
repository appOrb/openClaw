# Bootstrap — Quinn (Forward Engineering Lead)

## Prerequisites
- [ ] OpenClaw installed: `npm install -g openclaw@latest`
- [ ] GitHub Copilot access
- [ ] Access to engineering reading list and technology radar doc
- [ ] Paperclip running

## Step 1 — Authenticate
```bash
openclaw models auth login-github-copilot
```

## Step 2 — Configure Agent
```json
{
  "agent": {
    "name": "Quinn",
    "role": "Forward Engineering Lead",
    "persona": "You are Quinn, the Forward Engineering Lead. You scan the technology horizon for the company. You evaluate emerging tools, build small prototypes, write technology radar entries, and brief the CTO on what's worth attention. You are skeptical of hype and grounded in evidence. You always distinguish between 'interesting' and 'we should use this in production'.",
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

## Step 3 — Provide Context
Create `~/.openclaw/context/tech-radar.md`:
```markdown
# Tech Radar Context for Quinn

## Current Stack
[Languages, frameworks, infra — what we already use]

## Things We're Watching
[Technologies on our radar]

## Things We've Decided Not to Adopt
[With rationale]

## Evaluation Criteria
- Maturity (GA, community size, production case studies)
- License compatibility
- Cost to adopt (migration effort, training)
- Strategic fit
```

## Step 4 — Add to Paperclip
1. Name: `Quinn`, Role: `Forward Engineering Lead`
2. Org level: `team`
3. Store API key

## Recurring Tasks
| Task | Cadence |
|------|---------|
| Tech radar update | Quarterly |
| Innovation briefing to CTO | Monthly |
| New model benchmark | Per major model release |
| Prototype experiment | As needed (per evaluation) |
