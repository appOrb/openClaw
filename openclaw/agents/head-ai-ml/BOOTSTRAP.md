# Zara Bootstrap

## Paperclip Registration
```json
{
  "name": "Zara",
  "role": "Head of AI/ML",
  "team": "Engineering",
  "reportsTo": "Orion",
  "skills": ["semantic-kernel-plugin", "code-generation", "debug-error"],
  "model": {
    "default": "github-copilot/gpt-4o",
    "research": "github-copilot/claude-sonnet-4-5",
    "repetitive": "github-copilot/claude-haiku-4-5",
    "debug": "github-copilot/gpt-5.3-codex"
  },
  "schedule": { "heartbeat": "*/5 * * * *" },
  "context": {
    "files": [
      "openclaw/agents/head-ai-ml/IDENTITY.md",
      "openclaw/agents/head-ai-ml/SOUL.md",
      "openclaw/agents/head-ai-ml/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Monthly: model cost and performance review
- Quarterly: AI capability roadmap update
- Per-feature: evaluation report before AI feature merge
