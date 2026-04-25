# Discord Bot Setup Guide - 26 AI Agents

Complete guide to create Discord bot applications for all 26 AI agents.

---

## What You're Creating

26 independent Discord bot accounts that will represent your AI company's agents:
- 5 C-Suite executives
- 7 Engineering team members
- 6 Vice Presidents
- 4 Department Heads
- 4 Support roles

Each bot will have:
- Custom username
- Unique avatar (emoji)
- Specific channel permissions
- Ability to respond to messages
- Independent presence in Discord

---

## Prerequisites

- Discord account with application creation permissions
- Access to Discord Developer Portal: https://discord.com/developers/applications
- Server admin permissions to invite bots
- ~2-3 hours for all 26 bots

---

## Step-by-Step: Creating ONE Bot

Follow these steps for **each** of the 26 agents:

### 1. Create Application

1. Go to https://discord.com/developers/applications
2. Click **"New Application"**
3. Enter application name (e.g., "Alex Developer")
4. Accept Terms of Service
5. Click **"Create"**

### 2. Configure Bot

1. In left sidebar, click **"Bot"**
2. Click **"Add Bot"**
3. Confirm **"Yes, do it!"**
4. Configure bot settings:
   - **Username:** Set to agent name (e.g., "Alex Developer")
   - **Icon:** Upload an image or leave default (we'll use emoji in messages)
   - **Public Bot:** Turn OFF (keep private)
   - **Require OAuth2 Code Grant:** Turn OFF

### 3. Enable Privileged Intents

Still in Bot settings:

1. Scroll to **"Privileged Gateway Intents"**
2. Enable these intents:
   - ✅ **Message Content Intent** (REQUIRED - allows bot to read messages)
   - ✅ **Server Members Intent** (optional, for user info)
   - ❌ Presence Intent (not needed)

### 4. Copy Bot Token

1. Under **"Token"** section
2. Click **"Reset Token"** (first time) or **"Copy"** (if already created)
3. **IMPORTANT:** Save this token securely
4. Add to tokens.json (format below)

### 5. Set Permissions

1. In left sidebar, click **"OAuth2"** → **"URL Generator"**
2. Under **"Scopes"**, select:
   - ✅ **bot**
3. Under **"Bot Permissions"**, select:
   - ✅ **Read Messages/View Channels**
   - ✅ **Send Messages**
   - ✅ **Embed Links**
   - ✅ **Attach Files**
   - ✅ **Read Message History**
   - ✅ **Add Reactions**
   - ❌ (DO NOT enable admin, manage channels, manage roles, etc.)

4. Copy the generated URL at the bottom

### 6. Invite to Server

1. Open the URL you copied in step 5
2. Select your Discord server
3. Click **"Authorize"**
4. Complete CAPTCHA if prompted

---

## All 26 Agents - Creation Checklist

| # | Agent ID | Application Name | Username | Avatar | Priority | Channels |
|---|----------|-----------------|----------|---------|----------|----------|
| 1 | diana-ceo | Diana CEO | Diana (CEO) | 👔 | Critical | executive-suite, board-room, company-announcements |
| 2 | marcus-cto | Marcus CTO | Marcus (CTO) | ⚙️ | High | executive-suite, engineering-all, architecture |
| 3 | priya-cfo | Priya CFO | Priya (CFO) | 💰 | High | executive-suite, board-room, financial-ops |
| 4 | leo-cmo | Leo CMO | Leo (CMO) | 📢 | High | executive-suite, marketing-sales, product-strategy |
| 5 | coo | COO | COO | 🎯 | High | executive-suite, project-status, company-announcements |
| 6 | alex-developer | Alex Developer | Alex (Developer) | 💻 | High | dev-team, engineering-all, deployments, architecture |
| 7 | morgan-architect | Morgan Architect | Morgan (Architect) | 🏗️ | High | architecture, engineering-all, dev-team |
| 8 | sam-devsecops | Sam DevSecOps | Sam (DevSecOps) | 🔧 | High | deployments, engineering-all, security, dev-team |
| 9 | jordan-platform | Jordan Platform | Jordan (Platform) | 🛠️ | Medium | engineering-all, dev-team, deployments |
| 10 | sage-infrastructure | Sage Infrastructure | Sage (Infrastructure) | ☁️ | Medium | engineering-all, deployments, security |
| 11 | blake-security | Blake Security | Blake (Security) | 🔒 | Critical | security, incidents-escalations, engineering-all |
| 12 | quinn-forward-eng | Quinn Forward Eng | Quinn (Forward Eng) | 🔬 | Low | engineering-all, architecture |
| 13 | vp-engineering | VP Engineering | VP Engineering | 👨‍💼 | High | engineering-all, dev-team, executive-suite |
| 14 | vp-product | VP Product | VP Product | 📋 | High | product-strategy, engineering-all, executive-suite |
| 15 | vp-growth | VP Growth | VP Growth | 📈 | High | marketing-sales, product-strategy, executive-suite |
| 16 | vp-brand | VP Brand | VP Brand | 🎨 | Medium | marketing-sales, product-strategy |
| 17 | vp-finance | VP Finance | VP Finance | 💵 | Medium | financial-ops, executive-suite |
| 18 | vp-people | VP People | VP People | 👥 | Medium | executive-suite, company-announcements |
| 19 | head-ai-ml | Head AI ML | Head AI/ML | 🤖 | High | engineering-all, architecture, product-strategy |
| 20 | head-data | Head Data | Head Data | 📊 | Medium | engineering-all, product-strategy |
| 21 | head-content | Head Content | Head Content | ✍️ | Medium | marketing-sales, product-strategy |
| 22 | head-devrel | Head DevRel | Head DevRel | 🎤 | Medium | marketing-sales, engineering-all |
| 23 | qa | QA Engineer | QA Engineer | 🧪 | Medium | dev-team, engineering-all |
| 24 | revenue-ops | Revenue Ops | Revenue Ops | 💼 | Medium | marketing-sales, financial-ops |
| 25 | general-counsel | General Counsel | General Counsel | ⚖️ | Medium | executive-suite, board-room |
| 26 | chief-of-staff | Chief of Staff | Chief of Staff | 📝 | Medium | executive-suite, project-status |

---

## Token Management

### Create tokens.json

After creating all bots, create this file:

```json
{
  "version": "1.0",
  "created": "2026-04-25",
  "tokens": {
    "diana-ceo": "YOUR_BOT_TOKEN_HERE",
    "marcus-cto": "YOUR_BOT_TOKEN_HERE",
    "priya-cfo": "YOUR_BOT_TOKEN_HERE",
    "leo-cmo": "YOUR_BOT_TOKEN_HERE",
    "coo": "YOUR_BOT_TOKEN_HERE",
    "alex-developer": "YOUR_BOT_TOKEN_HERE",
    "morgan-architect": "YOUR_BOT_TOKEN_HERE",
    "sam-devsecops": "YOUR_BOT_TOKEN_HERE",
    "jordan-platform": "YOUR_BOT_TOKEN_HERE",
    "sage-infrastructure": "YOUR_BOT_TOKEN_HERE",
    "blake-security": "YOUR_BOT_TOKEN_HERE",
    "quinn-forward-eng": "YOUR_BOT_TOKEN_HERE",
    "vp-engineering": "YOUR_BOT_TOKEN_HERE",
    "vp-product": "YOUR_BOT_TOKEN_HERE",
    "vp-growth": "YOUR_BOT_TOKEN_HERE",
    "vp-brand": "YOUR_BOT_TOKEN_HERE",
    "vp-finance": "YOUR_BOT_TOKEN_HERE",
    "vp-people": "YOUR_BOT_TOKEN_HERE",
    "head-ai-ml": "YOUR_BOT_TOKEN_HERE",
    "head-data": "YOUR_BOT_TOKEN_HERE",
    "head-content": "YOUR_BOT_TOKEN_HERE",
    "head-devrel": "YOUR_BOT_TOKEN_HERE",
    "qa": "YOUR_BOT_TOKEN_HERE",
    "revenue-ops": "YOUR_BOT_TOKEN_HERE",
    "general-counsel": "YOUR_BOT_TOKEN_HERE",
    "chief-of-staff": "YOUR_BOT_TOKEN_HERE"
  }
}
```

Save to: `/home/azureuser/projects/appOrb/openClaw/openclaw/config/bot-tokens.json`

### Security

- ⚠️ **NEVER commit tokens to Git**
- ⚠️ **NEVER share tokens publicly**
- ✅ Add to .gitignore: `openclaw/config/bot-tokens.json`
- ✅ Store backup securely (password manager)
- ✅ Regenerate if compromised

---

## Invite URL Template

For each bot, the invite URL format:

```
https://discord.com/api/oauth2/authorize?client_id=YOUR_CLIENT_ID&permissions=277025508416&scope=bot
```

Replace `YOUR_CLIENT_ID` with the Application ID from the Developer Portal.

Permissions value `277025508416` includes:
- Read Messages/View Channels
- Send Messages
- Embed Links
- Attach Files
- Read Message History
- Add Reactions

---

## After Bot Creation

Once all 26 bots are created and tokens saved:

### 1. Verify Bots Are Online

Check your Discord server - you should see 26 new members (bots) offline.

### 2. Configure Channel Access

For each bot, configure channel-specific permissions:

**Example: Alex (Developer)**
- Grant access: #dev-team, #engineering-all, #deployments, #architecture
- Deny access: All other channels

**How to set:**
1. Right-click channel → Edit Channel
2. Permissions → Add Role or Member
3. Find bot by name
4. Set: View Channel ✅, Send Messages ✅

### 3. Deploy Bot Code

Once tokens are in bot-tokens.json, run:

```bash
cd /home/azureuser/projects/appOrb/openClaw
node openclaw/deploy-bots.js
```

This will:
- Load all 26 tokens
- Connect bots to Discord
- Set up message handlers
- Configure routing
- Activate agent sessions

### 4. Test Agents

In #dev-team channel:
```
@Alex (Developer) can you check the AI Waiter frontend status?
```

Alex bot should respond within 5-10 seconds.

---

## Troubleshooting

### Bot Not Responding

1. **Check bot is online:** Should show green status
2. **Verify token:** Regenerate if needed
3. **Check permissions:** Must have Read Messages + Send Messages
4. **Enable Message Content Intent:** Required to read messages
5. **Check logs:** `/home/azureuser/projects/appOrb/openClaw/logs/bot-{agent-id}.log`

### Bot Can't See Messages

- **Problem:** Message Content Intent not enabled
- **Fix:** Discord Developer Portal → Bot → Privileged Intents → Enable Message Content

### Bot Can't Post

- **Problem:** Missing Send Messages permission
- **Fix:** Channel settings → Permissions → Enable Send Messages

### Rate Limiting

- **Problem:** Too many bots posting at once
- **Fix:** Built-in queue system handles this automatically

---

## Resource Usage

### With 7 Bots Always-On

- RAM: ~700 MB (100 MB per bot)
- CPU: Minimal (<5% per bot)
- Network: ~10 KB/s total
- **Fits on current VM (4 GB RAM)**

### With All 26 Bots

- RAM: ~2.6 GB (100 MB per bot)
- CPU: Minimal (<20% total)
- Network: ~30 KB/s total
- **Requires VM upgrade or Army deployment**

---

## Cost Summary

- **Discord bot accounts:** FREE (unlimited)
- **Current VM (7 bots):** $13.50/month (no change)
- **Upgraded VM (26 bots):** $140/month (+$126)
- **Army 3 VMs (26 bots):** $81/month (+$67.50)

---

## Timeline

- **Bot creation (manual):** 5-7 min per bot × 26 = 2-3 hours
- **Token collection:** Already done during creation
- **Code deployment:** 15 minutes (automated)
- **Testing:** 30 minutes
- **Total:** 3-4 hours

---

## Next Steps

1. ☐ Create all 26 bot applications
2. ☐ Enable Message Content Intent for each
3. ☐ Copy all tokens to bot-tokens.json
4. ☐ Invite all bots to server
5. ☐ Configure channel permissions
6. ☐ Run deployment script
7. ☐ Test agents

Once complete, you'll have a fully operational multi-agent Discord company!

---

**Questions? Issues? Post in #engineering-all or tag @OpenClaw AppOrb**
