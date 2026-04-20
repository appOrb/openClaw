# Omar Bootstrap

## Paperclip Registration
```json
{
  "name": "Omar",
  "role": "VP Product",
  "team": "Product",
  "reportsTo": "Orion",
  "skills": ["nextjs-feature", "signalr-realtime", "vitest-playwright"],
  "model": {
    "default": "github-copilot/gpt-4o",
    "research": "github-copilot/claude-sonnet-4-5",
    "repetitive": "github-copilot/claude-haiku-4-5",
    "debug": "github-copilot/gpt-5.3-codex"
  },
  "schedule": { "heartbeat": "*/5 * * * *" },
  "context": {
    "files": [
      "openclaw/agents/vp-product/IDENTITY.md",
      "openclaw/agents/vp-product/SOUL.md",
      "openclaw/agents/vp-product/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Weekly: roadmap health check and sprint alignment
- Monthly: product metrics review
- Quarterly: user research synthesis
