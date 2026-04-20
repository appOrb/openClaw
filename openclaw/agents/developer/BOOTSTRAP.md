# Bootstrap — Alex (Developer Agent)

## Prerequisites
- [ ] OpenClaw installed: `npm install -g openclaw@latest`
- [ ] GitHub Copilot access (org or individual subscription)
- [ ] GitHub PAT with scopes: `repo`, `workflow`, `read:org`
- [ ] Paperclip running and accessible

## Step 1 — Authenticate GitHub Copilot
```bash
openclaw models auth login-github-copilot
# Follow the device-flow prompt in your browser
```

## Step 2 — Configure Agent
Copy `openclaw/config.json` to `~/.openclaw/openclaw.json` (or the Paperclip agent config path):
```bash
cp openclaw/config.json ~/.openclaw/openclaw.json
```

Key fields to verify:
```json
{
  "agent": {
    "name": "Alex",
    "role": "Senior Full-Stack Developer"
  },
  "provider": {
    "name": "github-copilot",
    "authMethod": "device-flow"
  }
}
```

## Step 3 — Install Skills
```bash
mkdir -p ~/.openclaw/skills
cp openclaw/skills/*.md ~/.openclaw/skills/
```

Enabled skills:
- `code-generation` — Write new code from spec
- `pr-creation` — Open GitHub PRs
- `code-review` — Review diffs inline
- `debug-error` — Investigate stack traces
- `scaffold-project` — Bootstrap new services
- `write-tests` — Generate test suites
- `setup-ci` — Create GitHub Actions workflows

## Step 4 — Add to Paperclip
1. Log in to Paperclip at `https://<your-fqdn>`
2. Go to **Agents** → **Add Agent**
3. Set name: `Alex`, role: `developer`
4. Paste the generated API key into `~/.openclaw/.env`:
   ```bash
   OPENCLAW_AGENT_KEY=<key>
   ```

## Step 5 — Start Gateway
```bash
openclaw gateway
# or via systemd:
systemctl start openclaw
```

## Step 6 — Verify
```bash
curl -s http://localhost:18789/health
# Expected: {"status":"ok"}
```

## Recurring Maintenance
| Task | Frequency |
|------|-----------|
| `npm update -g openclaw` | Weekly |
| Rotate GitHub PAT | Every 90 days |
| Review skill files for updates | Monthly |
