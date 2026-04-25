#!/bin/bash
# Install OpenClaw automation crontab

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔧 Installing OpenClaw Automation Crontab..."

# Create logs directory
mkdir -p "$PROJECT_ROOT/logs"

# Backup existing crontab
echo "💾 Backing up existing crontab..."
crontab -l > "$PROJECT_ROOT/logs/crontab.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || echo "No existing crontab"

# Install new crontab
echo "📝 Installing new crontab..."
crontab "$SCRIPT_DIR/crontab.conf"

echo "✅ Crontab installed successfully!"
echo ""
echo "📅 Scheduled Tasks:"
echo "  - Daily Standup: 9:00 AM UTC"
echo "  - Daily Metrics: 5:00 PM UTC"
echo "  - Weekly Summary: Sunday 8:00 PM UTC"
echo "  - Health Check: Every hour"
echo ""
echo "📂 Logs location: $PROJECT_ROOT/logs/"
echo ""
echo "🔍 View crontab: crontab -l"
echo "🗑️  Remove crontab: crontab -r"
