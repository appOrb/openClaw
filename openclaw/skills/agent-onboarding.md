---
name: agent-onboarding
description: Add a new OpenClaw agent to paperclip/company.yaml, create its identity files, and deploy to the live system
modelHint: research
---

# Agent Onboarding Skill

## Overview
Adding a new agent requires: identity files + company.yaml entry + Terraform apply.

## Step 1 — Create Identity Files
Create 4 files in `openclaw/agents/<role-name>/`:
- `IDENTITY.md` — role, domain, reports-to, what it owns
- `USER.md` — who it serves, request types, output formats
- `SOUL.md` — 5 core values, personality, what it defends
- `BOOTSTRAP.md` — config.json block, Paperclip registration, recurring tasks

Use `openclaw/agents/developer/` as the reference template.

## Step 2 — Add to paperclip/company.yaml
```yaml
agents:
  - name: AgentName
    role: Role Title
    team: Engineering  # or appropriate team
    skills:
      - skill-name-1
      - skill-name-2
    model:
      default: github-copilot/gpt-4o
      research: github-copilot/claude-sonnet-4-5
      repetitive: github-copilot/claude-haiku-4-5
      debug: github-copilot/gpt-5.3-codex
    schedule:
      heartbeat: "*/5 * * * *"
    context:
      files:
        - openclaw/agents/<role-name>/IDENTITY.md
        - openclaw/agents/<role-name>/SOUL.md
        - openclaw/agents/<role-name>/USER.md
```

## Step 3 — Deploy
```bash
cd infra/terraform
terraform apply -target=null_resource.paperclip_config
```

Or push to main and let GitHub Actions deploy.

## Verify
SSH to VM and check: `sudo journalctl -u paperclip -n 30 --no-pager`
Agent should appear as `idle` in the Paperclip dashboard.

## Naming Convention
- `name` in company.yaml = Paperclip call name (e.g., "Apex", "Maven")
- Identity docs use human persona names (e.g., "Diana", "Leo")
