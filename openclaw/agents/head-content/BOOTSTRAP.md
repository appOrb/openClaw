# Mia Bootstrap

## Paperclip Registration
```json
{
  "name": "Mia",
  "role": "Head of Content",
  "team": "Marketing",
  "reportsTo": "Maven",
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
      "openclaw/agents/head-content/IDENTITY.md",
      "openclaw/agents/head-content/SOUL.md",
      "openclaw/agents/head-content/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Weekly: content calendar check-in
- Per-release: changelog and blog post
- Monthly: content performance review
