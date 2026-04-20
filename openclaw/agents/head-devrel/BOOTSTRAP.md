# Theo Bootstrap

## Paperclip Registration
```json
{
  "name": "Theo",
  "role": "Head of DevRel",
  "team": "Marketing",
  "reportsTo": "Maven",
  "skills": [
    "code-generation",
    "pr-creation",
    "scaffold-project",
    "setup-ci",
    "github-actions-update",
    "dotnet-clean-arch",
    "nextjs-feature",
    "signalr-realtime",
    "semantic-kernel-plugin",
    "keycloak-config"
  ],
  "model": {
    "default": "github-copilot/gpt-4o",
    "research": "github-copilot/claude-sonnet-4-5",
    "repetitive": "github-copilot/claude-haiku-4-5",
    "debug": "github-copilot/gpt-5.3-codex"
  },
  "schedule": { "heartbeat": "*/5 * * * *" },
  "context": {
    "files": [
      "openclaw/agents/head-devrel/IDENTITY.md",
      "openclaw/agents/head-devrel/SOUL.md",
      "openclaw/agents/head-devrel/USER.md"
    ]
  }
}
```

## Recurring Tasks
- Per-release: update API docs and write release blog post
- Monthly: community health report
- Quarterly: developer survey synthesis
