# Cole Bootstrap

## Paperclip Registration
```json
{
  "name": "Cole",
  "role": "Revenue Operations Lead",
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
      "openclaw/agents/revenue-ops/IDENTITY.md",
      "openclaw/agents/revenue-ops/SOUL.md",
      "openclaw/agents/revenue-ops/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Weekly: pipeline review summary
- Monthly: revenue forecast update
- Quarterly: funnel conversion analysis
