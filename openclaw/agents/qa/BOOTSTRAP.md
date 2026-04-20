# Bootstrap — Vera (QA Agent)

## Prerequisites
- [ ] OpenClaw installed: `npm install -g openclaw@latest`
- [ ] GitHub Copilot access (org or individual subscription)
- [ ] Playwright MCP installed: `npx @playwright/mcp@latest`
- [ ] Node.js 20+ (for Playwright)
- [ ] Access to `https://openclaw-reevelobo.eastus.cloudapp.azure.com`
- [ ] Keycloak test user credentials (realm: `openclaw`, client: `paperclip`)

## Step 1 — Authenticate GitHub Copilot
```bash
openclaw models auth login-github-copilot
```

## Step 2 — Install Playwright + Dependencies
```bash
npm install -D @playwright/test @playwright/mcp axe-core @axe-core/playwright
npx playwright install chromium firefox webkit
```

## Step 3 — Configure Playwright MCP
Add to your MCP settings (`~/.config/Code/User/settings.json` or `mcp.json`):
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "env": {
        "PLAYWRIGHT_BASE_URL": "https://openclaw-reevelobo.eastus.cloudapp.azure.com"
      }
    }
  }
}
```

## Step 4 — Configure Agent
```json
{
  "agent": {
    "id": "d4e5f6a7-b8c9-0123-defa-456789abcdef",
    "name": "Vera",
    "role": "qa",
    "reportsTo": "Nadia"
  },
  "provider": {
    "name": "github-copilot",
    "authMethod": "device-flow",
    "models": {
      "default": "github-copilot/gpt-4o",
      "research": "github-copilot/claude-sonnet-4-5",
      "repetitive": "github-copilot/claude-haiku-4-5",
      "debug": "github-copilot/gpt-5.3-codex"
    }
  },
  "mcp": {
    "servers": ["playwright"]
  },
  "skills": [
    "playwright-mcp",
    "vitest-playwright",
    "write-tests",
    "debug-error",
    "code-review"
  ]
}
```

## Step 5 — Install Skills
```bash
mkdir -p ~/.openclaw/skills
cp openclaw/skills/playwright-mcp.md ~/.openclaw/skills/
cp openclaw/skills/vitest-playwright.md ~/.openclaw/skills/
cp openclaw/skills/write-tests.md ~/.openclaw/skills/
cp openclaw/skills/debug-error.md ~/.openclaw/skills/
cp openclaw/skills/code-review.md ~/.openclaw/skills/
```

## Step 6 — Add to Paperclip
1. Log in to Paperclip at `https://openclaw-reevelobo.eastus.cloudapp.azure.com`
2. Go to **Agents** → **Add Agent**
3. Set name: `Vera`, role: `qa`
4. Paste the generated API key into `~/.openclaw/.env`:
   ```bash
   OPENCLAW_AGENT_KEY=<key>
   ```

## Step 7 — Verify Playwright MCP Connection
```bash
# Should list available Playwright MCP tools
openclaw mcp list playwright
# Run a quick smoke test
npx playwright test --project=chromium tests/e2e/smoke.spec.ts
```

## Recurring Tasks

| Task | Frequency | Trigger |
|------|-----------|---------|
| Smoke test live environment | Daily | Cron 08:00 UTC |
| Full regression suite | Per PR | GitHub Actions `on: pull_request` |
| Visual regression baseline update | Per release | Manual after approved deploy |
| Accessibility scan | Weekly | Cron Monday 09:00 UTC |
| Flaky test review | Weekly | Review `test-results/` artifacts |
| Auth flow validation | Per deploy | Post-deploy hook |

## Key Test Paths
```
tests/
  e2e/
    smoke.spec.ts          # Homepage loads, login works, nav renders
    auth.spec.ts           # Full OIDC flow: Keycloak → oauth2-proxy → callback
    paperclip.spec.ts      # Paperclip UI: agents list, chat, task creation
    api.spec.ts            # API health, authenticated endpoints
    accessibility.spec.ts  # axe-core WCAG 2.1 AA scan on all pages
    visual.spec.ts         # Screenshot regression vs baseline
```

## Context Files
- `nginx/openclaw.conf` — proxy rules, auth routes
- `keycloak/` — realm config, client setup
- `paperclip/company.yaml` — registered agents
- `openclaw/skills/playwright-mcp.md` — Playwright MCP tool reference
