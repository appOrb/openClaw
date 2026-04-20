# Taylor Bootstrap

## Paperclip Registration
```json
{
  "name": "Taylor",
  "role": "General Counsel",
  "team": "Legal",
  "reportsTo": "Apex",
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
      "openclaw/agents/general-counsel/IDENTITY.md",
      "openclaw/agents/general-counsel/SOUL.md",
      "openclaw/agents/general-counsel/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Quarterly: open-source license audit
- Annually: privacy policy review
- As needed: contract and compliance reviews
