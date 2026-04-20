# Kai Bootstrap

## Paperclip Registration
```json
{
  "name": "Kai",
  "role": "VP Growth",
  "team": "Marketing",
  "reportsTo": "Maven",
  "skills": ["nextjs-feature", "vitest-playwright"],
  "model": {
    "default": "github-copilot/gpt-4o",
    "research": "github-copilot/claude-sonnet-4-5",
    "repetitive": "github-copilot/claude-haiku-4-5",
    "debug": "github-copilot/gpt-5.3-codex"
  },
  "schedule": { "heartbeat": "*/5 * * * *" },
  "context": {
    "files": [
      "openclaw/agents/vp-growth/IDENTITY.md",
      "openclaw/agents/vp-growth/SOUL.md",
      "openclaw/agents/vp-growth/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Weekly: growth metrics summary
- Monthly: experiment results and learnings
- Quarterly: growth loop audit
