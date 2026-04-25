# Automation Documentation

Complete automation system for OpenClaw multi-agent company monitoring and reporting.

Version: 1.0  
Last Updated: 2026-04-25

---

## 📋 Overview

**4 Automated Systems:**

1. **Daily Standup** - 9:00 AM UTC
2. **Metrics Reporting** - 5:00 PM UTC daily, 8:00 PM UTC Sunday
3. **Incident Alerts** - Real-time
4. **Health Checks** - Every hour

---

## 🤖 System 1: Daily Standup

**Script:** `openclaw/automation/daily-standup.sh`  
**Schedule:** 9:00 AM UTC daily  
**Channels:** #daily-standup + #owner-dashboard

### What It Does

- Lists all 26 agents and their current focus
- Reports yesterday's achievements
- Lists today's priorities (top 5)
- Identifies blockers
- Shows progress metrics
- Tracks OKR progress

### Output

- **#daily-standup:** Full standup report (~50 lines)
- **#owner-dashboard:** Condensed summary (~10 lines)

### Example Report

```
## 📊 Daily Standup - 2026-04-25 (Saturday)

**Active Agents (26 total)**

C-Suite (4):
- Diana (CEO) - Strategic planning
- Marcus (CTO) - Technical oversight
...

Yesterday's Achievements:
- Multi-agent organization designed
- Discord organization created
...

Today's Priorities:
1. Configure automation ✅
2. Complete agent registry (15 remaining)
...

Blockers: None

Progress Metrics:
- Agent Configuration: 42% (11/26)
- Revenue: $0 (Month 1 setup)
```

---

## 📊 System 2: Metrics Reporting

**Script:** `openclaw/automation/metrics-report.sh`  
**Schedule:** 5:00 PM UTC daily, 8:00 PM UTC Sunday (weekly)  
**Channels:** #metrics-reports + #owner-dashboard

### What It Does

**Daily Report (5 PM UTC):**
- Revenue metrics (MRR, customers, churn)
- Agent operations (status, activity, success rate)
- Engineering metrics (deployments, uptime, MTTR)
- Product metrics (SaaS status, beta customers)
- Sales & marketing (leads, conversion, engagement)
- OKR progress tracking
- Alerts & warnings

**Weekly Summary (Sunday 8 PM UTC):**
- Week's achievements
- Progress comparison
- Next week's goals
- Overall status

### Output

- **#metrics-reports:** Full KPI report (~100 lines)
- **#owner-dashboard:** 4-line summary

### Example Report

```
## 📈 Daily Metrics Report - 2026-04-25

💰 Revenue Metrics:
- MRR: $0 (Target: $100K)
- Customers: 0 (0 new)

🤖 Agent Operations:
- Configured: 11/26 (42%)
- Active Today: 1

⚙️ Engineering:
- Uptime: 100%
- Deployments: 0
- Incidents: 0

🎯 OKR Progress:
- Revenue: 🟢 On track (setup phase)
- Agents: 🟢 42% complete
- Product: 🟢 Planning AI Waiter
```

---

## 🚨 System 3: Incident Alerts

**Script:** `openclaw/automation/incident-alert.sh`  
**Trigger:** Called when incidents occur  
**Channels:** Routes based on severity

### Usage

```bash
./incident-alert.sh <severity> <category> <title> <description>
```

**Parameters:**
- **severity:** P0 (critical), P1 (high), P2 (medium), P3 (low)
- **category:** security, deployment, infrastructure, development, general
- **title:** Short incident title
- **description:** Detailed description

### Routing Rules

| Severity | Channels | Owner Notified | Response Time |
|----------|----------|----------------|---------------|
| P0 (Critical) | #incidents-escalations + #owner-dashboard + category | Yes (@mention) | < 15 minutes |
| P1 (High) | #incidents-escalations + #owner-dashboard + category | Yes (@mention) | < 1 hour |
| P2 (Medium) | Category channel only | No | < 4 hours |
| P3 (Low) | Category channel only | No | Next standup |

**Category Channels:**
- security → #security
- deployment/infrastructure → #deployments
- development → #dev-team
- general → #dev-team

### Example Usage

```bash
# P0 critical security incident
./incident-alert.sh P0 security \
  "Database Breach Detected" \
  "Unauthorized access to production database detected at 14:35 UTC"

# P1 high deployment failure
./incident-alert.sh P1 deployment \
  "Production Deployment Failed" \
  "Deploy #234 failed with build errors. Service degraded."

# P2 medium development issue
./incident-alert.sh P2 development \
  "Test Suite Failing" \
  "Integration tests failing on main branch after latest commit"

# P3 low infrastructure notice
./incident-alert.sh P3 infrastructure \
  "High Memory Usage" \
  "Dev VM memory at 85%, approaching threshold"
```

### Example Output

```
## 🔴 P0 Incident: Database Breach Detected

**Severity:** P0 (CRITICAL)
**Category:** security
**Time:** 2026-04-25 14:35 UTC

Description:
Unauthorized access to production database detected at 14:35 UTC

Action Required:
IMMEDIATE ACTION REQUIRED
- Assemble incident response team
- Notify all stakeholders
- Begin mitigation immediately
- Start incident log

Response Time: < 15 minutes
```

---

## 🏥 System 4: Health Checks

**Script:** `openclaw/automation/health-check.sh`  
**Schedule:** Every hour  
**Channels:** #agent-activity (healthy), #incidents-escalations (issues)

### What It Checks

1. **OpenClaw Process:** Is it running?
2. **Disk Space:** >90% triggers alert
3. **Memory Usage:** >90% triggers alert

### Alert Behavior

- **Healthy:** Logs to file (no Discord spam)
- **Issues:** Triggers P1 incident via `incident-alert.sh`

### Example Alert

If health check fails:

```
## 🟠 P1 Incident: Health Check Failed

Issues detected:
- Memory usage high: 95%
- Disk usage high: 92%
```

---

## 📅 Installation

### Step 1: Install Crontab

```bash
cd /home/azureuser/projects/appOrb/openClaw/openclaw/automation
./install-crontab.sh
```

This will:
- Backup existing crontab
- Install new scheduled tasks
- Create logs directory
- Display schedule confirmation

### Step 2: Verify Installation

```bash
# View installed crontab
crontab -l

# Expected output:
# 0 9 * * * .../daily-standup.sh
# 0 17 * * * .../metrics-report.sh
# 0 * * * * .../health-check.sh
```

### Step 3: Test Scripts Manually

```bash
# Test daily standup
./daily-standup.sh

# Test metrics report
./metrics-report.sh

# Test incident alert
./incident-alert.sh P3 general "Test Incident" "Testing alert system"

# Test health check
./health-check.sh
```

### Step 4: Check Logs

```bash
# View logs
tail -f ../../logs/standup.log
tail -f ../../logs/metrics.log
tail -f ../../logs/health.log
```

---

## 📊 Schedule Summary

| Time (UTC) | Task | Frequency | Channels |
|------------|------|-----------|----------|
| 09:00 | Daily Standup | Daily | #daily-standup, #owner-dashboard |
| 17:00 | Metrics Report | Daily | #metrics-reports, #owner-dashboard |
| 20:00 (Sun) | Weekly Summary | Weekly | #owner-dashboard |
| Every hour | Health Check | Hourly | #agent-activity (logs only) |
| Real-time | Incident Alerts | As needed | Based on severity |

---

## 🔧 Customization

### Change Schedule

Edit `openclaw/automation/crontab.conf`:

```bash
# Change standup to 8 AM UTC
0 8 * * * .../daily-standup.sh

# Run metrics twice daily (9 AM and 5 PM)
0 9,17 * * * .../metrics-report.sh

# Health check every 30 minutes
*/30 * * * * .../health-check.sh
```

Then reinstall: `./install-crontab.sh`

### Add Custom Metrics

Edit `openclaw/automation/metrics-report.sh`:

```bash
# Add new metric
CUSTOM_METRIC=$(calculate_custom_metric)

# Add to report
METRICS_REPORT+="
**Custom Metrics:**
- Custom: $CUSTOM_METRIC
"
```

### Add Health Checks

Edit `openclaw/automation/health-check.sh`:

```bash
# Check custom service
if ! pgrep -f "my-service" > /dev/null; then
  ISSUES+=("My service not running")
fi
```

---

## 🔍 Troubleshooting

### Cron Not Running

```bash
# Check if cron is running
systemctl status cron

# Start cron
sudo systemctl start cron

# View cron logs
journalctl -u cron
```

### Scripts Not Executing

```bash
# Check permissions
ls -la openclaw/automation/*.sh
# Should be: -rwxr-xr-x

# Fix if needed
chmod +x openclaw/automation/*.sh
```

### Discord Messages Not Sending

```bash
# Test Discord connection
openclaw message send \
  --channel discord \
  --target "channel:1497477423867105421" \
  --message "Test message"

# Check OpenClaw logs
openclaw logs
```

### Log Files Growing Large

```bash
# Rotate logs manually
cd /home/azureuser/projects/appOrb/openClaw/logs
gzip standup.log
mv standup.log.gz standup.$(date +%Y%m%d).log.gz
> standup.log

# Or set up logrotate
sudo nano /etc/logrotate.d/openclaw
```

---

## 📂 File Structure

```
openclaw/
├── automation/
│   ├── daily-standup.sh       # Daily standup bot
│   ├── metrics-report.sh      # Metrics reporting bot
│   ├── incident-alert.sh      # Incident routing
│   ├── health-check.sh        # System health monitoring
│   ├── crontab.conf           # Cron schedule
│   └── install-crontab.sh     # Installation script
│
└── logs/
    ├── standup.log            # Standup logs
    ├── metrics.log            # Metrics logs
    ├── health.log             # Health check logs
    └── crontab.backup.*       # Crontab backups
```

---

## 🎯 Next Steps

**After installation:**

1. ✅ Verify crontab: `crontab -l`
2. ✅ Test each script manually
3. ✅ Check Discord channels for output
4. ✅ Monitor logs for errors
5. ✅ Wait for first scheduled run (9 AM UTC tomorrow)

**For production:**

1. Set up log rotation
2. Add more health checks (database, APIs, etc.)
3. Configure alerting thresholds
4. Add custom metrics tracking
5. Integrate with real data sources

---

## 📞 Support

**Issues?**
- Check logs: `~/projects/appOrb/openClaw/logs/`
- Test manually: `./automation/[script].sh`
- View crontab: `crontab -l`
- Discord: #incidents-escalations

**Modifications?**
- Edit scripts in `openclaw/automation/`
- Test changes manually first
- Reinstall crontab: `./install-crontab.sh`
- Monitor logs after changes

---

**Automation system is ready to deploy!** 🚀
