# Iris Bootstrap

## Paperclip Registration
```json
{
  "name": "Iris",
  "role": "VP Finance",
  "team": "Finance",
  "reportsTo": "Priya",
  "skills": ["agent-onboarding"],
  "model": {
    "default": "github-copilot/gpt-4o",
    "research": "github-copilot/claude-sonnet-4-5",
    "repetitive": "github-copilot/claude-haiku-4-5",
    "debug": "github-copilot/gpt-5.3-codex"
  },
  "schedule": { "heartbeat": "*/5 * * * *" },
  "context": {
    "files": [
      "openclaw/agents/vp-finance/IDENTITY.md",
      "openclaw/agents/vp-finance/SOUL.md",
      "openclaw/agents/vp-finance/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Monthly: financial statements and burn rate update
- Quarterly: budget variance analysis
