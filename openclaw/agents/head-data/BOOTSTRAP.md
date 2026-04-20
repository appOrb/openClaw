# Felix Bootstrap

## Paperclip Registration
```json
{
  "name": "Felix",
  "role": "Head of Data",
  "team": "Engineering",
  "reportsTo": "Orion",
  "skills": ["postgres-migration", "redis-cache", "code-generation"],
  "model": {
    "default": "github-copilot/gpt-4o",
    "research": "github-copilot/claude-sonnet-4-5",
    "repetitive": "github-copilot/claude-haiku-4-5",
    "debug": "github-copilot/gpt-5.3-codex"
  },
  "schedule": { "heartbeat": "*/5 * * * *" },
  "context": {
    "files": [
      "openclaw/agents/head-data/IDENTITY.md",
      "openclaw/agents/head-data/SOUL.md",
      "openclaw/agents/head-data/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Monthly: slow query report
- Quarterly: schema review and technical debt
- Per-migration: review before merge
