# Nadia Bootstrap

## Paperclip Registration
```json
{
  "name": "Nadia",
  "role": "VP Engineering",
  "team": "Engineering",
  "reportsTo": "Orion",
  "skills": ["code-review", "github-actions-update", "dotnet-clean-arch", "nextjs-feature"],
  "model": {
    "default": "github-copilot/gpt-4o",
    "research": "github-copilot/claude-sonnet-4-5",
    "repetitive": "github-copilot/claude-haiku-4-5",
    "debug": "github-copilot/gpt-5.3-codex"
  },
  "schedule": { "heartbeat": "*/5 * * * *" },
  "context": {
    "files": [
      "openclaw/agents/vp-engineering/IDENTITY.md",
      "openclaw/agents/vp-engineering/SOUL.md",
      "openclaw/agents/vp-engineering/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Weekly: sprint status summary
- Monthly: DORA metrics report
- Quarterly: technical debt triage
