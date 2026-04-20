# Nova Bootstrap

## Paperclip Registration
```json
{
  "name": "Nova",
  "role": "VP Brand",
  "team": "Marketing",
  "reportsTo": "Maven",
  "skills": ["nextjs-feature", "agent-onboarding"],
  "model": {
    "default": "github-copilot/gpt-4o",
    "research": "github-copilot/claude-sonnet-4-5",
    "repetitive": "github-copilot/claude-haiku-4-5",
    "debug": "github-copilot/gpt-5.3-codex"
  },
  "schedule": { "heartbeat": "*/5 * * * *" },
  "context": {
    "files": [
      "openclaw/agents/vp-brand/IDENTITY.md",
      "openclaw/agents/vp-brand/SOUL.md",
      "openclaw/agents/vp-brand/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Per-release: design review for new UI components
- Quarterly: brand audit across all customer touchpoints
