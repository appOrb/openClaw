---
name: playwright-mcp
description: >
  Browser automation and E2E testing using the Playwright MCP server (@playwright/mcp).
  Use this skill to navigate pages, click elements, fill forms, take screenshots,
  check accessibility, and validate the full auth flow on the live OpenClaw environment.
modelHint: default
---

# Playwright MCP Skill

## What is Playwright MCP?
`@playwright/mcp` is an MCP server that exposes Playwright browser automation as MCP tools.
It lets AI agents control a real browser (Chromium, Firefox, WebKit) to test web applications.

## Installation
```bash
npx @playwright/mcp@latest
# or install globally:
npm install -g @playwright/mcp
```

## MCP Server Config
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

## Available MCP Tools (key subset)

| Tool | Description |
|------|-------------|
| `browser_navigate` | Navigate to a URL |
| `browser_snapshot` | Get accessibility tree snapshot of current page |
| `browser_click` | Click an element by ref from snapshot |
| `browser_type` | Type text into an input |
| `browser_fill_form` | Fill multiple form fields at once |
| `browser_take_screenshot` | Capture current page as PNG |
| `browser_wait_for` | Wait for text to appear/disappear |
| `browser_evaluate` | Run JavaScript in the page context |
| `browser_network_requests` | Inspect network traffic |
| `browser_console_messages` | Read browser console logs |

## Live OpenClaw Auth Flow Test
```typescript
// Full OIDC login test using Playwright MCP tools

// 1. Navigate to app
await browser_navigate({ url: "https://openclaw-reevelobo.eastus.cloudapp.azure.com" });

// 2. Should redirect to Keycloak login
await browser_wait_for({ text: "Sign In" });
const snapshot = await browser_snapshot();
// Find username/password fields in snapshot refs

// 3. Fill credentials
await browser_fill_form({
  fields: [
    { name: "username", type: "textbox", ref: "<ref>", value: "testuser" },
    { name: "password", type: "textbox", ref: "<ref>", value: "testpassword" }
  ]
});

// 4. Submit
await browser_press_key({ key: "Enter" });

// 5. Should land on Paperclip dashboard
await browser_wait_for({ text: "Agents" });
const finalSnapshot = await browser_snapshot();
// Assert agents list is visible
```

## Common Test Patterns

### Smoke Test
```typescript
// Navigate and confirm page loads
await browser_navigate({ url: BASE_URL });
await browser_take_screenshot({ type: "png", filename: "smoke-home.png" });
// Check for no error pages
const snapshot = await browser_snapshot();
// Verify no "Internal Server Error" text in snapshot
```

### 502/500 Detection
```typescript
await browser_navigate({ url: `${BASE_URL}/oauth2/callback?...` });
const snap = await browser_snapshot();
// Check snapshot does NOT contain "502 Bad Gateway" or "500 Internal Server Error"
```

### Check oauth2-proxy CSRF Cookie
```typescript
const snap = await browser_snapshot();
// Verify _oauth2_proxy_csrf cookie is set
// If missing, oauth2-proxy is likely down or misconfigured
const cookies = await browser_evaluate({
  function: "() => document.cookie"
});
```

### API Health Check
```typescript
await browser_navigate({ url: `${BASE_URL}/api/health` });
const content = await browser_evaluate({
  function: "() => document.body.innerText"
});
// Assert JSON contains { "status": "ok" }
```

### Accessibility Scan
```typescript
// Use axe-core injected via evaluate
await browser_navigate({ url: `${BASE_URL}/agents` });
await browser_evaluate({
  function: `async () => {
    const { default: axe } = await import('https://cdnjs.cloudflare.com/ajax/libs/axe-core/4.9.0/axe.min.js');
    return axe.run();
  }`
});
```

## Writing Playwright Test Files
```typescript
// tests/e2e/auth.spec.ts
import { test, expect } from "@playwright/test";

const BASE = process.env.BASE_URL ?? "https://openclaw-reevelobo.eastus.cloudapp.azure.com";

test.describe("Auth Flow", () => {
  test("login redirects to Keycloak", async ({ page }) => {
    await page.goto(BASE);
    await expect(page).toHaveURL(/\/auth\/realms\/openclaw/);
    await expect(page.getByRole("heading", { name: /sign in/i })).toBeVisible();
  });

  test("successful login lands on Paperclip dashboard", async ({ page }) => {
    await page.goto(BASE);
    await page.fill("#username", process.env.TEST_USER!);
    await page.fill("#password", process.env.TEST_PASS!);
    await page.click('[type=submit]');
    await expect(page).toHaveURL(BASE + "/");
    await expect(page.getByText("Agents")).toBeVisible();
  });

  test("oauth2 callback does not return 500", async ({ page }) => {
    const response = await page.goto(BASE);
    expect(response?.status()).not.toBe(500);
    expect(response?.status()).not.toBe(502);
  });
});
```

## Playwright Config for OpenClaw
```typescript
// playwright.config.ts
import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./tests/e2e",
  use: {
    baseURL: process.env.BASE_URL ?? "https://openclaw-reevelobo.eastus.cloudapp.azure.com",
    screenshot: "only-on-failure",
    trace: "on-first-retry",
    video: "on-first-retry",
    ignoreHTTPSErrors: false,
  },
  projects: [
    { name: "chromium", use: { browserName: "chromium" } },
    { name: "firefox", use: { browserName: "firefox" } },
  ],
  reporter: [
    ["html", { open: "never" }],
    ["github"],
    ["list"],
  ],
});
```

## CI Integration (GitHub Actions)
```yaml
# .github/workflows/playwright.yml
name: Playwright E2E

on:
  pull_request:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - run: npx playwright test
        env:
          BASE_URL: ${{ vars.BASE_URL }}
          TEST_USER: ${{ secrets.TEST_USER }}
          TEST_PASS: ${{ secrets.TEST_PASS }}
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
```

## Known OpenClaw Issues to Test For
| Issue | Test |
|-------|------|
| oauth2-proxy CSRF token errors (403) | Clear cookies before each auth test |
| oauth2-proxy → Paperclip 502 | Assert callback doesn't return 502 |
| Keycloak 500 on callback | Assert `/oauth2/callback` returns 200 |
| Agents fail to start (500 in UI) | Test agents list endpoint via API |
| WebSocket connection to gateway | Test SignalR connection on `/gateway` |
