# Discord Multi-Agent Implementation Plan

## System Analysis

**Current Capacity:**
- RAM: 3.8 GB total, 2.5 GB available
- CPU: 2 cores, load average: 0.00
- OpenClaw Gateway: 678 MB (stable)
- System load: Very low

**Assessment:** Current system can handle 26 Discord bot instances with proper resource management.

**Estimated Resource Impact:**
- Each bot: ~50-100 MB RAM
- 26 bots: ~1.3-2.6 GB total
- **Verdict:** Can run on current VM, but will use 60-80% of available memory
- **Recommendation:** Monitor closely, scale to 8GB VM if performance degrades

---

## Implementation Approach

### Option A: Multiple Bot Accounts (Full Implementation)
**Pros:**
- True multi-agent presence
- Each agent has unique identity
- Direct @mentions work natively
- Agents can react, post independently

**Cons:**
- Requires 26 Discord bot applications
- Complex token management
- Higher resource usage
- Discord API rate limits per bot

**Timeline:** 2+ hours (bot creation, token management, deployment)

### Option B: Single Bot with Webhook Impersonation (Recommended)
**Pros:**
- Single bot token
- Webhook API allows custom names/avatars per message
- Lower resource usage
- Faster implementation
- Easier to manage

**Cons:**
- @mentions require custom handling
- Webhooks can't react to messages (bot can)
- Slightly less "native" feel

**Timeline:** 20 minutes (feasible)

### Option C: Hybrid Approach (Best Balance)
**Pros:**
- Single OpenClaw bot for coordination
- Webhooks for agent messages with custom personas
- Bot handles @mention detection and routing
- Agent responses appear with agent name/avatar
- Full conversation threading

**Cons:**
- Custom mention parsing required
- Slightly more complex logic

**Timeline:** 30-40 minutes

---

## Recommended Implementation: Option C (Hybrid)

### Architecture

```
User @mentions agent in Discord
    ↓
OpenClaw bot detects mention
    ↓
Routes to agent workspace
    ↓
Agent processes with sessions_spawn
    ↓
Agent responds via webhook (custom name/avatar)
    ↓
Appears in Discord with agent persona
```

### Implementation Steps

1. **Create Discord Webhooks (5 min)**
   - One webhook per channel where agents operate
   - Store webhook URLs in config

2. **Create Agent Persona Mapping (5 min)**
   - Map agent IDs to names, avatars, roles
   - Define permission boundaries per agent

3. **Implement Mention Detection (5 min)**
   - Parse messages for @agent-name patterns
   - Route to appropriate agent workspace

4. **Implement Webhook Response (5 min)**
   - Agent responses use webhook API
   - Custom username and avatar per agent

5. **Add Agent Context (5 min)**
   - Agent receives: channel, conversation history, user context
   - Agent has access to: assigned channels only

6. **Test Multi-Agent Conversation (5 min)**
   - Spawn 3 agents in test channel
   - Verify routing, responses, threading

---

## Agent Persona Configuration

Each agent needs:

```json
{
  "id": "alex-developer",
  "name": "Alex (Developer)",
  "discord_handle": "alex-developer",
  "avatar_url": "https://example.com/alex.png",
  "role_id": "1234567890", // Discord role ID
  "allowed_channels": [
    "dev-team",
    "engineering-all",
    "deployments"
  ],
  "permissions": {
    "read": true,
    "write": true,
    "mention_users": false,
    "manage_channels": false,
    "admin": false
  },
  "auto_respond": [
    "code-review",
    "bug-fix",
    "feature-request"
  ]
}
```

---

## Discord Role Setup

**For each agent, create role with minimal permissions:**

Base permissions (all agents):
- ✅ Read Messages/View Channels
- ✅ Send Messages
- ✅ Embed Links
- ✅ Attach Files
- ✅ Read Message History
- ✅ Add Reactions
- ❌ Mention @everyone, @here, or All Roles
- ❌ Manage Messages
- ❌ Manage Channels
- ❌ Administrator

**Channel-specific access:**
- Engineering agents: #engineering-all, #dev-team, #architecture, #deployments, #security
- C-Suite agents: #executive-suite, #board-room, #financial-ops
- VPs: Department channels + cross-functional
- Support: Specific operational channels

---

## Scaling Considerations

### Current VM (2 CPU, 4 GB RAM)
- **Max agents active:** 10-15 simultaneously
- **Recommendation:** Stagger agent activation
- **Monitoring:** Track memory usage

### If Scaling Needed (8 CPU, 16 GB RAM)
- **Max agents active:** 26+ simultaneously
- **Cost:** ~$150/month (Standard_D2s_v3)
- **When:** If >10 agents active at once regularly

### Alternative: Agent Army Deployment
- **2 VMs:** 9 agents per VM
- **Cost:** $54/month (already documented)
- **Benefit:** Load distribution
- **Setup time:** 30 minutes (terraform ready)

---

## Implementation Timeline (20 Minutes)

**Minutes 0-5:** Create webhook per channel
**Minutes 5-10:** Configure agent persona mapping
**Minutes 10-15:** Implement mention routing logic
**Minutes 15-18:** Test with 3 agents
**Minutes 18-20:** Deploy and verify

---

## Proposed Agent Distribution

### Always Active (Core Operations)
- Diana (CEO) - #executive-suite, #board-room, #company-announcements
- Marcus (CTO) - #executive-suite, #engineering-all, #architecture
- Alex (Developer) - #dev-team, #deployments
- Sam (DevSecOps) - #deployments, #security
- Blake (Security) - #security, #incidents-escalations

### Trigger-Based (On Demand)
- All other 21 agents spawn when @mentioned or triggered by keywords

---

## Next Steps

**Option 1: Proceed with 20-min implementation (Hybrid approach)**
- Create webhooks now
- Build mention routing
- Test with 3 agents
- Deploy incrementally

**Option 2: Scale VM first, then implement (40 min total)**
- Upgrade to 8GB RAM VM (20 min)
- Implement full 26-agent presence (20 min)
- Higher resource headroom

**Option 3: Deploy to Army VMs (60 min total)**
- Spin up 2 VMs with terraform (30 min)
- Distribute 26 agents (13 per VM)
- Full load distribution

**Recommendation:** Option 1 (proceed with hybrid approach on current VM, scale if needed)

---

## Risk Mitigation

**If resource constraint:**
- Limit concurrent agents to 10
- Queue remaining agent requests
- Auto-scale trigger at 80% memory

**If Discord rate limits:**
- Implement exponential backoff
- Share rate limit pool across agents
- Prioritize critical messages

**If coordination complexity:**
- Use OpenClaw orchestrator as single point
- Agents don't spawn other agents directly
- All routing through main bot

---

**Ready to proceed with 20-minute implementation?**
