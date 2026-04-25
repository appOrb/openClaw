#!/bin/bash
# OpenClaw Automation Scheduler
# Alternative to crontab - runs automation based on time checks
# Call this script from HEARTBEAT.md or manually

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
STATE_FILE="$PROJECT_ROOT/logs/scheduler-state.json"

# Create logs directory
mkdir -p "$PROJECT_ROOT/logs"

# Initialize state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
  echo '{"last_standup": null, "last_metrics": null, "last_health": null}' > "$STATE_FILE"
fi

# Get current time
CURRENT_HOUR=$(date -u +"%H")
CURRENT_MINUTE=$(date -u +"%M")
CURRENT_DAY=$(date -u +"%u")  # 1=Monday, 7=Sunday
TODAY=$(date -u +"%Y-%m-%d")

echo "🕐 Scheduler running at $(date -u +"%H:%M UTC")"

# Read state
LAST_STANDUP=$(jq -r '.last_standup' "$STATE_FILE")
LAST_METRICS=$(jq -r '.last_metrics' "$STATE_FILE")
LAST_HEALTH=$(jq -r '.last_health' "$STATE_FILE")

# Function to update state
update_state() {
  local key=$1
  local value=$2
  jq ".$key = \"$value\"" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
}

# Daily Standup - 9:00 AM UTC
if [ "$CURRENT_HOUR" -eq 9 ] && [ "$LAST_STANDUP" != "$TODAY" ]; then
  echo "📊 Running daily standup..."
  "$SCRIPT_DIR/daily-standup.sh" >> "$PROJECT_ROOT/logs/standup.log" 2>&1 || echo "Standup failed"
  update_state "last_standup" "$TODAY"
fi

# Metrics Report - 5:00 PM UTC (17:00)
if [ "$CURRENT_HOUR" -eq 17 ] && [ "$LAST_METRICS" != "$TODAY" ]; then
  echo "📈 Running metrics report..."
  "$SCRIPT_DIR/metrics-report.sh" >> "$PROJECT_ROOT/logs/metrics.log" 2>&1 || echo "Metrics failed"
  update_state "last_metrics" "$TODAY"
fi

# Health Check - Every hour
CURRENT_HOUR_KEY="${TODAY}_${CURRENT_HOUR}"
if [ "$LAST_HEALTH" != "$CURRENT_HOUR_KEY" ]; then
  echo "🏥 Running health check..."
  "$SCRIPT_DIR/health-check.sh" >> "$PROJECT_ROOT/logs/health.log" 2>&1 || echo "Health check failed"
  update_state "last_health" "$CURRENT_HOUR_KEY"
fi

echo "✅ Scheduler complete"
