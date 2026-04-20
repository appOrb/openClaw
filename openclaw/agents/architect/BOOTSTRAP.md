# Bootstrap — Morgan (Architect Agent)

## Prerequisites
- [ ] OpenClaw installed: `npm install -g openclaw@latest`
- [ ] GitHub Copilot access
- [ ] GitHub PAT with scopes: `repo`, `read:org`
- [ ] Paperclip running
- [ ] `docs/adr/` directory exists in target repositories

## Step 1 — Authenticate GitHub Copilot
```bash
openclaw models auth login-github-copilot
```

## Step 2 — Configure Agent
Create `~/.openclaw/openclaw.json`:
```json
{
  "agent": {
    "name": "Morgan",
    "role": "Principal Architect",
    "persona": "You are Morgan, the Principal Architect. You design systems, write ADRs, define API contracts, and evaluate technology choices. You think in systems, document every decision, and always present tradeoffs before making recommendations. You do not implement code — you define what should be built and why.",
    "language": "en"
  },
  "models": {
    "routing": {
      "research":   "github-copilot/claude-sonnet-4.5",
      "creative":   "github-copilot/claude-sonnet-4.5",
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

## Step 3 — Add to Paperclip
1. Log in to Paperclip
2. **Agents** → **Add Agent**
3. Name: `Morgan`, Role: `architect`
4. Set API key in environment:
   ```bash
   OPENCLAW_AGENT_KEY=<key>
   ```

## Step 4 — Create ADR Directory
In each repository Morgan will work with:
```bash
mkdir -p docs/adr
cat > docs/adr/0001-record-architecture-decisions.md << 'EOF'
# 1. Record Architecture Decisions

## Status
Accepted

## Context
We need to record significant architectural decisions made for this project.

## Decision
We will use Markdown Architectural Decision Records (MADR).

## Consequences
Decisions are documented and discoverable. New team members can understand why the system is shaped the way it is.
EOF
```

## Step 5 — Start Gateway
```bash
systemctl start openclaw
# or: openclaw gateway
```

## Recurring Maintenance
| Task | Frequency |
|------|-----------|
| Review pending ADRs for superseded status | Monthly |
| Technology radar update | Quarterly |
| API contract validation against live services | On deploy |
