# Multi-Agent Discord Integration

Complete system for routing Discord messages to 26 specialized AI agents.

## Architecture

```
Discord Message
    ↓
OpenClaw Bot detects message
    ↓
agent-router.js parses message
    ↓
Identifies relevant agents (@mentions + keywords)
    ↓
agent-spawn.sh prepares agent tasks
    ↓
OpenClaw sessions_spawn creates agent sessions
    ↓
Agent processes request in workspace
    ↓
Agent responds (appears with custom persona)
    ↓
Posted to Discord channel
```

## Components

### 1. agent-personas.json (10.9 KB)
26 agent configurations with:
- Discord handles (@agent-name)
- Avatar emojis
- Color codes
- Channel access lists
- Trigger keywords
- Auto-response flags
- Priority levels

### 2. agent-router.js (6.7 KB)
Node.js routing system:
- Parses @mentions using regex
- Matches trigger keywords (fuzzy)
- Filters by channel access
- Sorts by priority + confidence
- Limits concurrent agents (max 10)
- Timeout management (30 seconds)

### 3. agent-spawn.sh (2.2 KB)
Bash wrapper for spawning:
- Calls agent-router.js to get agents
- Builds context-aware tasks
- Prepares for sessions_spawn
- Manages agent workspaces

## Usage

### Route a Message
```bash
node agent-router.js route "<message>" <channel> [senderId]
```

Example:
```bash
node agent-router.js route "@alex-developer fix the bug" "dev-team" "user123"
```

Output:
```json
[
  {
    "agentId": "alex-developer",
    "workspace": "/path/to/agent/workspace",
    "displayInfo": {
      "username": "Alex (Developer)",
      "avatar": "💻",
      "color": 6970061
    },
    "priority": "high",
    "context": {
      "channel": "dev-team",
      "senderId": "user123",
      "message": "@alex-developer fix the bug",
      "trigger": "mention"
    }
  }
]
```

### Get Channel Agents
```bash
node agent-router.js channel-agents <channel>
```

Example:
```bash
node agent-router.js channel-agents "dev-team"
```

Output:
```json
[
  {
    "id": "alex-developer",
    "name": "Alex (Developer)",
    "handle": "alex-developer",
    "autoRespond": true
  },
  {
    "id": "sam-devsecops",
    "name": "Sam (DevSecOps)",
    "handle": "sam-devsecops",
    "autoRespond": true
  }
]
```

### Get Agent Info
```bash
node agent-router.js agent-info <agentId>
```

## Agent Personas

### Always-Active Agents (5)
Auto-respond to keywords in their channels:

1. **Diana (CEO)** - @diana-ceo
   - Channels: executive-suite, board-room, company-announcements
   - Triggers: strategic, ceo, company-direction, board
   - Priority: Critical

2. **Marcus (CTO)** - @marcus-cto
   - Channels: executive-suite, engineering-all, architecture
   - Triggers: technical, cto, architecture, engineering
   - Priority: High

3. **Alex (Developer)** - @alex-developer
   - Channels: dev-team, engineering-all, deployments, architecture
   - Triggers: bug, feature, code, implement
   - Priority: High

4. **Sam (DevSecOps)** - @sam-devsecops
   - Channels: deployments, engineering-all, security, dev-team
   - Triggers: pipeline, deployment, ci-cd, github-actions
   - Priority: High

5. **Blake (Security)** - @blake-security
   - Channels: security, incidents-escalations, engineering-all
   - Triggers: security, vulnerability, incident, breach
   - Priority: Critical

### Trigger-Based Agents (21)
Spawn on @mention or when explicitly invoked:

**C-Suite:**
- Priya (CFO) - @priya-cfo
- Leo (CMO) - @leo-cmo
- COO - @coo

**Engineering:**
- Morgan (Architect) - @morgan-architect
- Jordan (Platform) - @jordan-platform
- Sage (Infrastructure) - @sage-infrastructure
- Quinn (Forward Eng) - @quinn-forward-eng

**VPs:**
- VP Engineering - @vp-engineering
- VP Product - @vp-product
- VP Growth - @vp-growth
- VP Brand - @vp-brand
- VP Finance - @vp-finance
- VP People - @vp-people

**Department Heads:**
- Head AI/ML - @head-ai-ml
- Head Data - @head-data
- Head Content - @head-content
- Head DevRel - @head-devrel

**Support:**
- QA - @qa
- Revenue Ops - @revenue-ops
- General Counsel - @general-counsel
- Chief of Staff - @chief-of-staff

## Routing Rules

### Priority Levels
1. **Critical** (P0): Immediate response, bypasses queue
2. **High** (P1): Front of queue, <1 hour SLA
3. **Medium** (P2): Normal queue, <4 hours SLA
4. **Low** (P3): Best effort, <24 hours SLA

### Matching Logic
1. **Direct @mention**: 100% confidence, always routes
2. **Keyword trigger**: 70% confidence, routes if auto_respond=true
3. **Channel access**: Only route if agent has channel access
4. **Concurrent limit**: Max 10 agents active simultaneously
5. **Timeout**: Agent marked inactive after 30 seconds

### Example Routing

**Input:** "@alex-developer can you review this code?"  
**Channel:** dev-team  
**Output:** Routes to alex-developer (mention, 100% confidence)

**Input:** "We have a security vulnerability in production"  
**Channel:** security  
**Output:** Routes to blake-security (keyword: "security" + "vulnerability", 70% confidence)

**Input:** "I need help with architecture"  
**Channel:** marketing-sales  
**Output:** No route (morgan-architect doesn't have access to marketing-sales)

## Channel Access Matrix

| Agent | executive-suite | board-room | financial-ops | engineering-all | dev-team | architecture | deployments | security |
|-------|----------------|------------|---------------|----------------|----------|--------------|-------------|----------|
| Diana (CEO) | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Marcus (CTO) | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ |
| Priya (CFO) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Leo (CMO) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Alex (Developer) | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Sam (DevSecOps) | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Blake (Security) | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ✅ |

(See agent-personas.json for complete matrix)

## Integration with OpenClaw

### Current State
- ✅ Routing system complete
- ✅ Agent personas configured
- ✅ Channel access control
- ✅ Priority queueing
- ⏳ OpenClaw sessions_spawn integration (pending)
- ⏳ Discord webhook setup (pending)
- ⏳ Response posting (pending)

### Next Steps for Full Integration

1. **Create Discord Webhooks**
   - One webhook per channel
   - Store URLs in webhooks.json
   - Use for posting agent responses with custom personas

2. **Integrate with OpenClaw Gateway**
   - Hook into message event handler
   - Call agent-router.js on every message
   - Pass results to sessions_spawn

3. **Implement sessions_spawn Wrapper**
   - Create agent sessions with context
   - Pass workspace path
   - Set label for tracking

4. **Configure Response Posting**
   - Agent completes task
   - Extract response
   - Post via webhook with custom username/avatar
   - Thread responses appropriately

## Testing

### Test 1: Direct Mention
```bash
./test-router.sh "@alex-developer" "dev-team"
# Expected: Routes to alex-developer
```

### Test 2: Keyword Trigger
```bash
./test-router.sh "we have a security issue" "security"
# Expected: Routes to blake-security (auto-respond)
```

### Test 3: Multiple Agents
```bash
./test-router.sh "@marcus-cto @alex-developer we need architecture review" "engineering-all"
# Expected: Routes to both marcus-cto and alex-developer
```

### Test 4: Channel Access Denial
```bash
./test-router.sh "@alex-developer" "financial-ops"
# Expected: No route (alex doesn't have access)
```

### Test 5: Concurrent Limit
```bash
# Spawn 15 agents simultaneously
# Expected: Only first 10 routed, rest queued
```

## Monitoring

### Agent Activity Logs
Location: #agent-activity channel

What's logged:
- Agent spawns (timestamp, agent, trigger)
- Agent responses (timestamp, agent, channel)
- Routing decisions (agent, channel, confidence)
- Errors (timeouts, access denied, spawn failures)

### Metrics
- Agents spawned per hour
- Average response time
- Success rate
- Most active agents
- Most active channels

## Resource Usage

### Current System (4 GB RAM)
- Router: ~20 MB
- Per agent session: ~50-100 MB
- Max 10 concurrent: ~1 GB
- **Total with overhead: ~1.5 GB**
- **Remaining available: 1 GB** (safe margin)

### If Scaling Needed
Upgrade to 8 GB RAM:
- Cost: ~$100/month additional
- Capacity: 26+ concurrent agents
- When: If regularly hitting 10-agent limit

## Security

### Agent Permissions
- ✅ Read-only access to channels
- ✅ Can post messages (via webhook)
- ❌ Cannot manage channels
- ❌ Cannot manage roles
- ❌ Cannot kick/ban users
- ❌ No admin permissions

### Channel Isolation
- Engineering agents can't access financial channels
- Financial agents can't access engineering channels
- Only C-suite has cross-functional access
- Owner always has full access

### Rate Limiting
- 10 concurrent agents max
- 30-second timeout per agent
- Exponential backoff on Discord API errors
- Graceful degradation under load

## Troubleshooting

### Agent Not Responding
1. Check channel access (agent-personas.json)
2. Verify trigger keywords match
3. Check if max concurrent limit reached
4. Review #agent-activity logs

### Wrong Agent Responding
1. Check trigger keyword conflicts
2. Verify channel access
3. Adjust persona confidence thresholds

### Performance Issues
1. Check concurrent agent count
2. Monitor RAM usage
3. Review timeout settings
4. Consider VM upgrade or army deployment

---

**Status:** System ready for OpenClaw gateway integration
**Timeline:** Core routing complete (15 min), integration pending (5 min)
**Next:** Hook into OpenClaw message handler and implement webhook posting
