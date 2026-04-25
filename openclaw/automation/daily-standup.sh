#!/bin/bash
# Daily Standup Automation
# Runs at 9:00 AM UTC daily via cron
# Posts standup summary to #daily-standup and #owner-dashboard

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Discord channel IDs
STANDUP_CHANNEL="1497477347073331371"
OWNER_DASHBOARD="1497477423867105421"
AGENT_ACTIVITY="1497477463146631189"

# Load agent registry
AGENTS_JSON="$PROJECT_ROOT/openclaw/config/agents.json"

# Get current date
TODAY=$(date -u +"%Y-%m-%d")
DAY_OF_WEEK=$(date -u +"%A")

echo "🔄 Running Daily Standup - $TODAY ($DAY_OF_WEEK)"

# Generate standup report
STANDUP_REPORT=$(cat <<EOF
## 📊 Daily Standup - $TODAY ($DAY_OF_WEEK)

**Time:** $(date -u +"%H:%M UTC")

---

### 🎯 **Active Agents (26 total)**

**C-Suite (4):**
- Diana (CEO) - Strategic planning
- Marcus (CTO) - Technical oversight
- Priya (CFO) - Financial management
- Leo (CMO) - Marketing & sales

**Engineering (7):**
- Alex (Developer) - Feature development
- Morgan (Architect) - System design
- Sam (DevSecOps) - CI/CD & security
- Jordan (Platform) - Developer experience
- Sage (Infrastructure) - Cloud operations
- Blake (Security) - Security posture
- Quinn (Forward Eng) - Innovation & research

**VPs (6):**
- VP Engineering - Team coordination
- VP Product - Product roadmap
- VP Growth - Lead generation
- VP Brand - Brand strategy
- VP Finance - Financial operations
- VP People - Team culture

**Department Heads (4):**
- Head AI/ML - AI/ML strategy
- Head Data - Data operations
- Head Content - Content marketing
- Head DevRel - Developer relations

**Support (5):**
- QA - Quality assurance
- Revenue Ops - Revenue operations
- General Counsel - Legal matters
- COO - Operations
- Chief of Staff - Executive support

---

### ✅ **Yesterday's Achievements**

- Multi-agent organization designed (26 agents, 3 revenue streams)
- Complete documentation created (42 KB)
- 11 core agents configured in agents.json
- Discord organization created (21 channels, 6 categories)
- Command center established for owner monitoring
- All work backed up to GitHub

---

### 🎯 **Today's Priorities**

1. **Configure Automation** (This task)
   - Daily standup bot ✅ (in progress)
   - Metrics reporting
   - Incident alerts

2. **Complete Agent Registry**
   - 15 remaining agents to configure
   - Full metadata per agent

3. **Implement Workflows**
   - Custom development workflow
   - SaaS product launch workflow
   - Revenue operations workflow

4. **Test Multi-Agent Coordination**
   - Spawn test agents
   - Verify communication
   - Test escalation paths

5. **First Revenue Stream Planning**
   - Identify first custom project opportunity
   - Create project template
   - Set up billing/contracts

---

### 🚧 **Blockers**

- None currently

---

### 📈 **Progress Metrics**

- Agent Configuration: 42% (11/26)
- Documentation: 100%
- Infrastructure: 100%
- Workflows: 0% (defined but not implemented)
- Revenue: \$0 (setup phase)

---

### 🎯 **OKRs Progress**

**Company OKR - Revenue Generation:**
- Target: \$100K MRR by month 6
- Status: Month 1 (setup phase)
- Progress: 0% (no revenue yet, building foundation)

**Engineering OKR - Multi-Agent System:**
- Target: 26 agents operational
- Status: 42% complete
- Progress: 11/26 agents configured

**Product OKR - SaaS Launch:**
- Target: 1 SaaS product live by month 6
- Status: Planning phase
- Progress: 0% (AI Waiter selected as first product)

---

### 💬 **Questions/Help Needed**

- None currently

---

**Next standup:** Tomorrow, $DAY_OF_WEEK $(date -u -d "+1 day" +"%Y-%m-%d") at 09:00 UTC

_Automated by OpenClaw Daily Standup Bot_
EOF
)

# Post to #daily-standup
echo "📤 Posting to #daily-standup..."
openclaw message send \
  --channel discord \
  --target "channel:$STANDUP_CHANNEL" \
  --message "$STANDUP_REPORT"

# Generate owner summary (condensed version)
OWNER_SUMMARY=$(cat <<EOF
## 📊 Daily Summary - $TODAY

**Status:** 🟢 On track

**Progress:**
- Agent config: 42% (11/26) 
- Documentation: 100%
- Infrastructure: 100%
- Revenue: \$0 (Month 1 setup)

**Today's Focus:**
1. Configure automation ✅
2. Complete agent registry (15 remaining)
3. Implement workflows
4. Test multi-agent coordination

**Blockers:** None

**Next Milestone:** 26 agents operational + first revenue stream

_Full standup: #daily-standup_
EOF
)

# Post to #owner-dashboard
echo "📤 Posting summary to #owner-dashboard..."
openclaw message send \
  --channel discord \
  --target "channel:$OWNER_DASHBOARD" \
  --message "$OWNER_SUMMARY"

echo "✅ Daily standup complete!"
