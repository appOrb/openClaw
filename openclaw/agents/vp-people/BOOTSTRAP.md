# Avery Bootstrap

## Paperclip Registration
```json
{
  "name": "Avery",
  "role": "VP People",
  "team": "Operations",
  "reportsTo": "Casey",
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
      "openclaw/agents/vp-people/IDENTITY.md",
      "openclaw/agents/vp-people/SOUL.md",
      "openclaw/agents/vp-people/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Quarterly: skills gap analysis across all teams
- Monthly: team health pulse summary
