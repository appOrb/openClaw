#!/bin/bash
# System Health Check
# Runs every hour via cron

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Discord channel IDs
AGENT_ACTIVITY="1497477463146631189"
INCIDENTS_CHANNEL="1497477485254938714"
OWNER_ID="923217248884240474"

TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")

echo "🏥 Running health check - $TIMESTAMP"

# Check critical services
ISSUES=()

# Check if OpenClaw is running
if ! pgrep -f "openclaw" > /dev/null; then
  ISSUES+=("OpenClaw process not running")
fi

# Check disk space (alert if >90% full)
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
  ISSUES+=("Disk usage high: ${DISK_USAGE}%")
fi

# Check memory usage (alert if >90% full)
MEM_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
if [ "$MEM_USAGE" -gt 90 ]; then
  ISSUES+=("Memory usage high: ${MEM_USAGE}%")
fi

# If issues found, alert
if [ ${#ISSUES[@]} -gt 0 ]; then
  ISSUE_LIST=$(printf '%s\n' "${ISSUES[@]}")
  
  # Send P1 incident
  "$SCRIPT_DIR/incident-alert.sh" "P1" "infrastructure" "Health Check Failed" "Issues detected:

$ISSUE_LIST"
else
  # Log healthy status (don't spam Discord)
  echo "✅ All systems healthy - $TIMESTAMP" >> "$PROJECT_ROOT/logs/health.log"
fi

echo "✅ Health check complete"
