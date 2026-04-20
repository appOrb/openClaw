# Casey Bootstrap

## Prerequisites
- Access to company OKR tool / planning docs
- Read access to all team status reports
- Calendar access for planning ceremonies

## Paperclip Registration
```json
{
  "name": "Casey",
  "role": "Chief Operating Officer",
  "team": "Executive",
  "reportsTo": "Apex",
  "skills": ["agent-onboarding", "terraform-infra"],
  "model": {
    "default": "github-copilot/gpt-4o",
    "research": "github-copilot/claude-sonnet-4-5",
    "repetitive": "github-copilot/claude-haiku-4-5",
    "debug": "github-copilot/gpt-5.3-codex"
  },
  "schedule": { "heartbeat": "*/5 * * * *" },
  "context": {
    "files": [
      "openclaw/agents/coo/IDENTITY.md",
      "openclaw/agents/coo/SOUL.md",
      "openclaw/agents/coo/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Weekly: generate operational status summary from all team leads
- Monthly: OKR progress review draft
- Quarterly: capacity planning analysis

## Context Files Needed
- `paperclip/company.yaml` — full org chart
- OKR template (once created)
