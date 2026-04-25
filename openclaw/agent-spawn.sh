#!/bin/bash
# Agent Spawn Wrapper - Routes Discord messages to agent sessions

ROUTER_PATH="/home/azureuser/projects/appOrb/openClaw/openclaw/agent-router.js"
PERSONAS_PATH="/home/azureuser/projects/appOrb/openClaw/openclaw/config/agent-personas.json"

# Parse arguments
MESSAGE="$1"
CHANNEL="$2"
SENDER_ID="${3:-unknown}"
MESSAGE_ID="${4:-unknown}"

if [ -z "$MESSAGE" ] || [ -z "$CHANNEL" ]; then
  echo "Usage: $0 <message> <channel> [sender_id] [message_id]"
  exit 1
fi

# Route message to determine which agents to spawn
AGENTS_TO_SPAWN=$(node "$ROUTER_PATH" route "$MESSAGE" "$CHANNEL" "$SENDER_ID")

if [ "$AGENTS_TO_SPAWN" == "[]" ]; then
  echo "No agents matched for routing"
  exit 0
fi

# Parse JSON and spawn each agent
echo "$AGENTS_TO_SPAWN" | jq -c '.[]' | while read -r agent; do
  AGENT_ID=$(echo "$agent" | jq -r '.agentId')
  WORKSPACE=$(echo "$agent" | jq -r '.workspace')
  PRIORITY=$(echo "$agent" | jq -r '.priority')
  TRIGGER=$(echo "$agent" | jq -r '.context.trigger')
  
  echo "Spawning agent: $AGENT_ID (priority: $PRIORITY, trigger: $TRIGGER)"
  
  # Build agent task
  TASK="You are responding to a message in Discord channel #${CHANNEL}.

**Message:** $MESSAGE
**Sender:** $SENDER_ID
**Trigger:** $TRIGGER

**Your Role:** $(echo "$agent" | jq -r '.displayInfo.username')

**Context from OPERATIONS.md:**
- You have access to complete operational knowledge
- Respond as your persona (see IDENTITY.md in your workspace)
- Keep responses focused and actionable
- Use your emoji signature when appropriate
- Post updates to appropriate channels

**Instructions:**
1. Analyze the message in context of your role
2. Provide a helpful, focused response
3. If action required, create a plan
4. If coordinating with other agents, tag them appropriately

Respond naturally as your character would."

  # Spawn agent session (this would integrate with OpenClaw's sessions_spawn)
  echo "Agent task prepared for $AGENT_ID"
  echo "Task: $TASK"
  echo "Workspace: $WORKSPACE"
  echo "---"
  
  # Note: Actual spawning would use OpenClaw's sessions_spawn tool
  # Example: openclaw sessions_spawn --task "$TASK" --workspace "$WORKSPACE" --label "$AGENT_ID-$MESSAGE_ID"
done

echo "Agent routing complete"
