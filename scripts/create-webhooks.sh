#!/bin/bash
# Create webhooks for agent communication channels

GUILD_ID="1496046200007299122"

# Channel IDs for webhook creation
declare -A CHANNELS=(
  ["executive-suite"]="1497477086577692692"
  ["board-room"]="1497477106194714744"
  ["financial-ops"]="1497477123563192390"
  ["engineering-all"]="1497477163241181327"
  ["dev-team"]="1497477183218647091"
  ["architecture"]="1497477203099914352"
  ["deployments"]="1497477220837621861"
  ["security"]="1497477237388218480"
  ["product-strategy"]="1497477273660559382"
  ["marketing-sales"]="1497477294745452614"
  ["customer-success"]="1497477312168591413"
  ["daily-standup"]="1497477347073331371"
  ["project-status"]="1497477365406892052"
  ["company-announcements"]="1497477386021765282"
  ["owner-dashboard"]="1497477423867105421"
  ["metrics-reports"]="1497477442418249818"
  ["agent-activity"]="1497477463146631189"
  ["incidents-escalations"]="1497477485254938714"
)

echo "# Webhook Configuration" > /home/azureuser/projects/appOrb/openClaw/openclaw/config/webhooks.json
echo "{" >> /home/azureuser/projects/appOrb/openClaw/openclaw/config/webhooks.json
echo '  "guild_id": "'$GUILD_ID'",' >> /home/azureuser/projects/appOrb/openClaw/openclaw/config/webhooks.json
echo '  "webhooks": {' >> /home/azureuser/projects/appOrb/openClaw/openclaw/config/webhooks.json

# Note: Actual webhook creation requires Discord bot API calls
# This script generates the config structure
echo "Webhook configuration structure created"
