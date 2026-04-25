# Subagent Implementation Guide

**Complete setup for 26-agent revenue-generating organization**

Version: 1.0  
Last Updated: 2026-04-25

---

## 🎯 Goal

Configure OpenClaw to run as a complete AI company with:
- 26 specialized agents
- Clear responsibilities
- Revenue-focused workflows
- Single point of contact (OpenClaw AppOrb = me)

---

## 📁 Directory Structure

```
/home/azureuser/projects/appOrb/openClaw/
├── openclaw/
│   ├── agents/                    # 26 agent profiles (existing)
│   │   ├── ceo/
│   │   ├── cto/
│   │   ├── cfo/
│   │   ├── cmo/
│   │   ├── developer/
│   │   ├── architect/
│   │   ├── devsecops/
│   │   ├── platform/
│   │   ├── infrastructure/
│   │   ├── security/
│   │   ├── forward-engineering/
│   │   ├── qa/
│   │   ├── vp-product/
│   │   ├── vp-engineering/
│   │   ├── vp-growth/
│   │   ├── vp-brand/
│   │   ├── vp-finance/
│   │   ├── vp-people/
│   │   ├── head-ai-ml/
│   │   ├── head-data/
│   │   ├── head-content/
│   │   ├── head-devrel/
│   │   ├── revenue-ops/
│   │   ├── general-counsel/
│   │   ├── coo/
│   │   └── chief-of-staff/
│   │
│   ├── config/
│   │   ├── agents.json            # Agent registry (NEW)
│   │   ├── workflows.json         # Workflow definitions (NEW)
│   │   └── permissions.json       # Access control (NEW)
│   │
│   └── workflows/
│       ├── custom-development.json
│       ├── saas-launch.json
│       ├── revenue-ops.json
│       └── emergency-response.json
│
├── .github/
│   └── workflows/
│       ├── spawn-agent.yml
│       ├── client-project.yml
│       ├── product-launch.yml
│       └── daily-standup.yml
│
└── docs/
    ├── SUBAGENT_ARCHITECTURE.md   # Overall design (created)
    ├── IMPLEMENTATION_GUIDE.md    # This file
    ├── WORKFLOWS.md               # Workflow documentation
    └── RUNBOOK.md                 # Operations guide
```

---

## 🔧 Step 1: Agent Registry Configuration

Create `/openclaw/config/agents.json`:

```json
{
  "version": "1.0",
  "orchestrator": {
    "id": "main",
    "name": "OpenClaw AppOrb",
    "role": "orchestrator",
    "description": "Single point of contact, coordinates all agents"
  },
  "agents": [
    {
      "id": "diana-ceo",
      "name": "Diana",
      "role": "ceo",
      "title": "Chief Executive Officer",
      "activation": "strategic-decision",
      "priority": "critical",
      "model": "claude-sonnet-4.5",
      "workspace": "/home/azureuser/projects/appOrb/openClaw/openclaw/agents/ceo",
      "reports_to": "user",
      "manages": ["marcus-cto", "leo-cmo", "priya-cfo", "coo"],
      "skills": ["strategy", "okrs", "fundraising", "board-management"],
      "budget_authority": 1000000,
      "decision_authority": "all"
    },
    {
      "id": "marcus-cto",
      "name": "Marcus",
      "role": "cto",
      "title": "Chief Technology Officer",
      "activation": "technical-decision",
      "priority": "high",
      "model": "claude-sonnet-4.5",
      "workspace": "/home/azureuser/projects/appOrb/openClaw/openclaw/agents/cto",
      "reports_to": "diana-ceo",
      "manages": ["vp-engineering", "vp-product", "head-ai-ml"],
      "skills": ["architecture", "technical-strategy", "team-building"],
      "budget_authority": 100000,
      "decision_authority": "technology"
    },
    {
      "id": "priya-cfo",
      "name": "Priya",
      "role": "cfo",
      "title": "Chief Financial Officer",
      "activation": "financial-decision",
      "priority": "high",
      "model": "claude-sonnet-4.5",
      "workspace": "/home/azureuser/projects/appOrb/openClaw/openclaw/agents/cfo",
      "reports_to": "diana-ceo",
      "manages": ["vp-finance", "revenue-ops"],
      "skills": ["financial-modeling", "budgeting", "forecasting", "reporting"],
      "budget_authority": 100000,
      "decision_authority": "finance"
    },
    {
      "id": "leo-cmo",
      "name": "Leo",
      "role": "cmo",
      "title": "Chief Marketing Officer",
      "activation": "marketing-campaign",
      "priority": "high",
      "model": "claude-sonnet-4.5",
      "workspace": "/home/azureuser/projects/appOrb/openClaw/openclaw/agents/cmo",
      "reports_to": "diana-ceo",
      "manages": ["vp-growth", "vp-brand", "head-content", "head-devrel"],
      "skills": ["marketing", "branding", "demand-generation", "sales"],
      "budget_authority": 50000,
      "decision_authority": "marketing"
    },
    {
      "id": "alex-developer",
      "name": "Alex",
      "role": "developer",
      "title": "Senior Full-Stack Developer",
      "activation": "feature-request,bug-fix,code-review",
      "priority": "high",
      "model": "claude-sonnet-4.5",
      "workspace": "/home/azureuser/projects/appOrb/openClaw/openclaw/agents/developer",
      "reports_to": "vp-engineering",
      "manages": [],
      "skills": ["typescript", "react", "node", "testing", "git"],
      "budget_authority": 1000,
      "decision_authority": "implementation"
    },
    {
      "id": "morgan-architect",
      "name": "Morgan",
      "role": "architect",
      "title": "Principal Architect",
      "activation": "architecture-decision",
      "priority": "high",
      "model": "claude-sonnet-4.5",
      "workspace": "/home/azureuser/projects/appOrb/openClaw/openclaw/agents/architect",
      "reports_to": "marcus-cto",
      "manages": [],
      "skills": ["system-design", "architecture", "adr", "api-design"],
      "budget_authority": 5000,
      "decision_authority": "architecture"
    },
    {
      "id": "sam-devsecops",
      "name": "Sam",
      "role": "devsecops",
      "title": "DevSecOps Engineer",
      "activation": "pipeline-failure,security-scan",
      "priority": "high",
      "model": "claude-sonnet-4.5",
      "workspace": "/home/azureuser/projects/appOrb/openClaw/openclaw/agents/devsecops",
      "reports_to": "vp-engineering",
      "manages": [],
      "skills": ["ci-cd", "security", "automation", "monitoring"],
      "budget_authority": 5000,
      "decision_authority": "pipeline"
    },
    {
      "id": "jordan-platform",
      "name": "Jordan",
      "role": "platform",
      "title": "Platform Engineer",
      "activation": "platform-issue,developer-experience",
      "priority": "medium",
      "model": "claude-sonnet-4.5",
      "workspace": "/home/azureuser/projects/appOrb/openClaw/openclaw/agents/platform",
      "reports_to": "vp-engineering",
      "manages": [],
      "skills": ["platform", "tooling", "developer-experience", "backstage"],
      "budget_authority": 5000,
      "decision_authority": "platform"
    },
    {
      "id": "sage-infrastructure",
      "name": "Sage",
      "role": "infrastructure",
      "title": "Infrastructure Engineer",
      "activation": "infrastructure-change,scaling",
      "priority": "medium",
      "model": "claude-sonnet-4.5",
      "workspace": "/home/azureuser/projects/appOrb/openClaw/openclaw/agents/infrastructure",
      "reports_to": "vp-engineering",
      "manages": [],
      "skills": ["terraform", "azure", "kubernetes", "networking"],
      "budget_authority": 10000,
      "decision_authority": "infrastructure"
    },
    {
      "id": "blake-security",
      "name": "Blake",
      "role": "security",
      "title": "Security Engineer",
      "activation": "security-incident,vulnerability",
      "priority": "critical",
      "model": "claude-sonnet-4.5",
      "workspace": "/home/azureuser/projects/appOrb/openClaw/openclaw/agents/security",
      "reports_to": "marcus-cto",
      "manages": [],
      "skills": ["security", "threat-modeling", "incident-response", "compliance"],
      "budget_authority": 5000,
      "decision_authority": "security"
    },
    {
      "id": "quinn-forward-eng",
      "name": "Quinn",
      "role": "forward-engineering",
      "title": "Forward Engineering Lead",
      "activation": "innovation,research,prototype",
      "priority": "low",
      "model": "claude-sonnet-4.5",
      "workspace": "/home/azureuser/projects/appOrb/openClaw/openclaw/agents/forward-engineering",
      "reports_to": "marcus-cto",
      "manages": [],
      "skills": ["research", "prototyping", "innovation", "emerging-tech"],
      "budget_authority": 10000,
      "decision_authority": "research"
    }
  ]
}
```

*(Additional 15 agents would be added similarly)*

---

## 🔄 Step 2: Workflow Definitions

Create `/openclaw/config/workflows.json`:

```json
{
  "workflows": {
    "custom-development": {
      "name": "Custom Development Project",
      "trigger": "label:new-client-project",
      "stages": [
        {
          "name": "Lead Qualification",
          "agents": ["leo-cmo", "vp-growth"],
          "parallel": true,
          "sla_hours": 24,
          "outputs": ["qualified", "rejected"]
        },
        {
          "name": "Discovery",
          "agents": ["vp-product", "morgan-architect", "priya-cfo"],
          "parallel": true,
          "sla_hours": 336,
          "outputs": ["proposal"]
        },
        {
          "name": "Contract",
          "agents": ["general-counsel", "priya-cfo"],
          "parallel": false,
          "sla_hours": 72,
          "outputs": ["signed"]
        },
        {
          "name": "Development",
          "agents": ["alex-developer", "blake-security", "qa"],
          "parallel": true,
          "sla_hours": 672,
          "outputs": ["code-complete"]
        },
        {
          "name": "Deployment",
          "agents": ["sage-infrastructure", "sam-devsecops", "jordan-platform"],
          "parallel": false,
          "sla_hours": 48,
          "outputs": ["deployed"]
        }
      ],
      "notifications": {
        "channel": "discord:1496046200481382553",
        "frequency": "daily",
        "escalation": "user"
      }
    },
    "saas-launch": {
      "name": "SaaS Product Launch",
      "trigger": "label:new-saas-product",
      "stages": [
        {
          "name": "Strategy",
          "agents": ["diana-ceo", "marcus-cto", "leo-cmo", "priya-cfo"],
          "parallel": true,
          "sla_hours": 168
        },
        {
          "name": "Design",
          "agents": ["morgan-architect", "head-ai-ml", "blake-security"],
          "parallel": true,
          "sla_hours": 168
        },
        {
          "name": "Development",
          "agents": ["alex-developer", "head-ai-ml", "sage-infrastructure", "qa"],
          "parallel": true,
          "sla_hours": 1344
        },
        {
          "name": "Beta",
          "agents": ["vp-growth", "vp-product", "alex-developer", "head-data"],
          "parallel": true,
          "sla_hours": 672
        },
        {
          "name": "GTM",
          "agents": ["leo-cmo", "vp-growth", "head-content", "head-devrel"],
          "parallel": true,
          "sla_hours": 0,
          "continuous": true
        }
      ]
    }
  }
}
```

---

## 🔐 Step 3: Permissions Configuration

Create `/openclaw/config/permissions.json`:

```json
{
  "budget_levels": {
    "exec": 100000,
    "vp": 50000,
    "senior": 10000,
    "individual": 1000
  },
  "code_access": {
    "write": ["alex-developer", "morgan-architect", "sam-devsecops"],
    "review": ["vp-engineering", "marcus-cto"],
    "deploy": ["sam-devsecops", "jordan-platform"]
  },
  "financial_access": {
    "approve": ["priya-cfo", "diana-ceo"],
    "view": ["revenue-ops", "vp-finance"]
  },
  "customer_access": {
    "communicate": ["leo-cmo", "vp-growth", "revenue-ops"],
    "contract": ["general-counsel", "priya-cfo", "diana-ceo"]
  }
}
```

---

## 🚀 Step 4: Spawn Script

Create `scripts/spawn-agent.sh`:

```bash
#!/bin/bash
# Spawn a subagent with proper configuration

AGENT_ID=$1
TASK=$2
WORKSPACE="/home/azureuser/projects/appOrb/openClaw/openclaw/agents/$AGENT_ID"

if [ ! -d "$WORKSPACE" ]; then
    echo "Error: Agent workspace not found: $WORKSPACE"
    exit 1
fi

# Load agent config
AGENT_CONFIG=$(jq -r ".agents[] | select(.id==\"$AGENT_ID\")" /home/azureuser/projects/appOrb/openClaw/openclaw/config/agents.json)

if [ -z "$AGENT_CONFIG" ]; then
    echo "Error: Agent not found in registry: $AGENT_ID"
    exit 1
fi

# Extract configuration
AGENT_NAME=$(echo "$AGENT_CONFIG" | jq -r .name)
AGENT_ROLE=$(echo "$AGENT_CONFIG" | jq -r .role)
AGENT_MODEL=$(echo "$AGENT_CONFIG" | jq -r .model)

echo "Spawning agent: $AGENT_NAME ($AGENT_ROLE)"
echo "Task: $TASK"
echo "Model: $AGENT_MODEL"

# Spawn via OpenClaw sessions_spawn
openclaw sessions spawn \
  --runtime subagent \
  --agent-id "$AGENT_ID" \
  --workspace "$WORKSPACE" \
  --task "$TASK" \
  --model "$AGENT_MODEL" \
  --label "$AGENT_NAME"
```

---

## 📊 Step 5: Monitoring Dashboard

Create `/openclaw/config/dashboard.json`:

```json
{
  "metrics": {
    "revenue": {
      "mrr": 0,
      "target_mrr": 100000,
      "deals_in_pipeline": 0,
      "deals_closed_this_month": 0
    },
    "engineering": {
      "active_agents": 0,
      "tasks_in_progress": 0,
      "deployment_frequency": "0/day",
      "lead_time_hours": 0,
      "mttr_hours": 0
    },
    "marketing": {
      "leads_this_month": 0,
      "conversion_rate": 0,
      "content_published": 0,
      "website_visitors": 0
    }
  },
  "alerts": {
    "p0_incidents": [],
    "budget_overruns": [],
    "at_risk_projects": []
  }
}
```

---

## 🔄 Step 6: GitHub Actions Integration

Create `.github/workflows/spawn-agent.yml`:

```yaml
name: Spawn Agent

on:
  workflow_dispatch:
    inputs:
      agent_id:
        description: 'Agent ID (e.g., alex-developer)'
        required: true
      task:
        description: 'Task description'
        required: true
      priority:
        description: 'Priority (low/medium/high/critical)'
        required: false
        default: 'medium'

jobs:
  spawn:
    runs-on: self-hosted
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Spawn Agent
        run: |
          ./scripts/spawn-agent.sh "${{ github.event.inputs.agent_id }}" "${{ github.event.inputs.task }}"
      
      - name: Notify Discord
        uses: discord/webhook@v1
        with:
          webhook-url: ${{ secrets.DISCORD_WEBHOOK }}
          content: |
            🤖 **Agent Spawned**
            Agent: `${{ github.event.inputs.agent_id }}`
            Task: ${{ github.event.inputs.task }}
            Priority: ${{ github.event.inputs.priority }}
```

---

## 📝 Step 7: Documentation

Create the remaining docs:

1. **WORKFLOWS.md** - Detailed workflow documentation
2. **RUNBOOK.md** - Daily operations guide
3. **API_REFERENCE.md** - Agent spawning API
4. **TROUBLESHOOTING.md** - Common issues & solutions

---

## ✅ Validation Checklist

Before going live, verify:

- [ ] All 26 agent workspaces exist
- [ ] agents.json has all 26 agents configured
- [ ] workflows.json has at least 3 workflows
- [ ] permissions.json is configured
- [ ] spawn-agent.sh is executable
- [ ] GitHub Actions workflow is valid
- [ ] Discord webhook is configured
- [ ] Metrics dashboard is accessible
- [ ] All agents have IDENTITY.md, SOUL.md, USER.md
- [ ] Test spawn for at least 3 agents

---

## 🎯 Next Steps

1. ✅ Review this guide
2. ⏳ Create configuration files
3. ⏳ Test agent spawning
4. ⏳ Deploy to GitHub
5. ⏳ Start first client project

---

**Ready to implement!** 🚀
