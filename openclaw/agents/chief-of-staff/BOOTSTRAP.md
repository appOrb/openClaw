# River Bootstrap

## Paperclip Registration
```json
{
  "name": "River",
  "role": "Chief of Staff",
  "team": "Executive",
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
      "openclaw/agents/chief-of-staff/IDENTITY.md",
      "openclaw/agents/chief-of-staff/SOUL.md",
      "openclaw/agents/chief-of-staff/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Daily: triage open requests flagged to CEO
- Weekly: executive briefing synthesis
- Monthly: strategic initiative health report
