#!/bin/bash
# Incident Alert System
# Called when incidents occur
# Routes alerts based on severity

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Discord channel IDs
INCIDENTS_CHANNEL="1497477485254938714"
OWNER_DASHBOARD="1497477423867105421"
DEPLOYMENTS_CHANNEL="1497477220837621861"
SECURITY_CHANNEL="1497477237388218480"
DEV_TEAM_CHANNEL="1497477183218647091"

# Discord user IDs
OWNER_ID="923217248884240474"

# Usage: ./incident-alert.sh <severity> <category> <title> <description>
SEVERITY="${1:-P3}"
CATEGORY="${2:-general}"
TITLE="${3:-Incident}"
DESCRIPTION="${4:-No description provided}"

TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")

echo "🚨 Processing incident: $SEVERITY - $TITLE"

# Determine emoji based on severity
case "$SEVERITY" in
  P0)
    EMOJI="🔴"
    URGENCY="CRITICAL"
    ;;
  P1)
    EMOJI="🟠"
    URGENCY="HIGH"
    ;;
  P2)
    EMOJI="🟡"
    URGENCY="MEDIUM"
    ;;
  P3)
    EMOJI="🔵"
    URGENCY="LOW"
    ;;
  *)
    EMOJI="⚪"
    URGENCY="INFO"
    ;;
esac

# Generate incident report
INCIDENT_REPORT=$(cat <<EOF
## $EMOJI **$SEVERITY Incident: $TITLE**

**Severity:** $SEVERITY ($URGENCY)
**Category:** $CATEGORY
**Time:** $TIMESTAMP

---

### 📋 **Description**

$DESCRIPTION

---

### 🎯 **Action Required**

EOF
)

# Add appropriate action based on severity
case "$SEVERITY" in
  P0)
    INCIDENT_REPORT+="**IMMEDIATE ACTION REQUIRED**

- Assemble incident response team
- Notify all stakeholders
- Begin mitigation immediately
- Start incident log

**Response Time:** < 15 minutes"
    ;;
  P1)
    INCIDENT_REPORT+="**Urgent attention needed**

- Review incident details
- Assign incident owner
- Begin investigation
- Provide status updates every hour

**Response Time:** < 1 hour"
    ;;
  P2)
    INCIDENT_REPORT+="**Scheduled response**

- Triage and prioritize
- Assign to appropriate team
- Track in project management
- Resolve within SLA

**Response Time:** < 4 hours"
    ;;
  P3)
    INCIDENT_REPORT+="**Normal workflow**

- Log in tracking system
- Add to team backlog
- Address in next sprint

**Response Time:** Next standup"
    ;;
esac

INCIDENT_REPORT+="

---

_Automated by OpenClaw Incident Alert System_"

# Route to appropriate channels based on severity and category
case "$SEVERITY" in
  P0|P1)
    # Critical/High: Owner dashboard + incidents channel + @owner
    echo "📤 Posting to #incidents-escalations and #owner-dashboard..."
    openclaw message send \
      --channel discord \
      --target "channel:$INCIDENTS_CHANNEL" \
      --message "<@$OWNER_ID>

$INCIDENT_REPORT"
    
    openclaw message send \
      --channel discord \
      --target "channel:$OWNER_DASHBOARD" \
      --message "$INCIDENT_REPORT"
    
    # Also route to category-specific channel
    case "$CATEGORY" in
      security)
        openclaw message send \
          --channel discord \
          --target "channel:$SECURITY_CHANNEL" \
          --message "$INCIDENT_REPORT"
        ;;
      deployment|infrastructure)
        openclaw message send \
          --channel discord \
          --target "channel:$DEPLOYMENTS_CHANNEL" \
          --message "$INCIDENT_REPORT"
        ;;
      development)
        openclaw message send \
          --channel discord \
          --target "channel:$DEV_TEAM_CHANNEL" \
          --message "$INCIDENT_REPORT"
        ;;
    esac
    ;;
    
  P2)
    # Medium: Category-specific channel only
    case "$CATEGORY" in
      security)
        openclaw message send \
          --channel discord \
          --target "channel:$SECURITY_CHANNEL" \
          --message "$INCIDENT_REPORT"
        ;;
      deployment|infrastructure)
        openclaw message send \
          --channel discord \
          --target "channel:$DEPLOYMENTS_CHANNEL" \
          --message "$INCIDENT_REPORT"
        ;;
      development|*)
        openclaw message send \
          --channel discord \
          --target "channel:$DEV_TEAM_CHANNEL" \
          --message "$INCIDENT_REPORT"
        ;;
    esac
    ;;
    
  P3)
    # Low: Team channel only
    case "$CATEGORY" in
      security)
        openclaw message send \
          --channel discord \
          --target "channel:$SECURITY_CHANNEL" \
          --message "$INCIDENT_REPORT"
        ;;
      deployment|infrastructure)
        openclaw message send \
          --channel discord \
          --target "channel:$DEPLOYMENTS_CHANNEL" \
          --message "$INCIDENT_REPORT"
        ;;
      *)
        openclaw message send \
          --channel discord \
          --target "channel:$DEV_TEAM_CHANNEL" \
          --message "$INCIDENT_REPORT"
        ;;
    esac
    ;;
esac

echo "✅ Incident alert sent!"
