#!/bin/bash
# Agent Spawn - Creates OpenClaw session for a specific agent

PERSONAS_PATH="/home/azureuser/projects/appOrb/openClaw/openclaw/config/agent-personas.json"

# Parse arguments
AGENT_ID="$1"
MESSAGE="$2"
CHANNEL="$3"
SENDER_ID="${4:-unknown}"
MESSAGE_ID="${5:-unknown}"

if [ -z "$AGENT_ID" ] || [ -z "$MESSAGE" ] || [ -z "$CHANNEL" ]; then
  echo "Usage: $0 <agent_id> <message> <channel> [sender_id] [message_id]"
  exit 1
fi

# Load agent persona
AGENT_DATA=$(jq -r ".personas[\"$AGENT_ID\"]" "$PERSONAS_PATH")

if [ -z "$AGENT_DATA" ] || [ "$AGENT_DATA" == "null" ]; then
  echo "Error: Agent $AGENT_ID not found in personas"
  exit 1
fi

# Extract agent details
AGENT_NAME=$(echo "$AGENT_DATA" | jq -r '.name')
AGENT_EMOJI=$(echo "$AGENT_DATA" | jq -r '.avatar_emoji')
WORKSPACE="/home/azureuser/projects/appOrb/openClaw/openclaw/agents/${AGENT_ID}"

# Build agent task with full context
TASK="**Discord Message Route:**
Channel: #${CHANNEL}
Message: ${MESSAGE}
Sender: ${SENDER_ID}
Message ID: ${MESSAGE_ID}

**Your Identity:** ${AGENT_NAME} ${AGENT_EMOJI}

**Task:**
You were mentioned in the message above. Respond as your character:
1. Read your workspace IDENTITY.md for your role and capabilities
2. Read OPERATIONS.md for current system context
3. Provide a focused, helpful response in your voice
4. If actions needed, outline next steps
5. Tag other agents if coordination required

Respond now as ${AGENT_NAME}."

echo "✓ Agent session prepared: $AGENT_ID"
echo "Workspace: $WORKSPACE"
echo "Task length: $(echo "$TASK" | wc -c) bytes"

# Output task for parent process to handle
cat <<EOF
{
  "agentId": "$AGENT_ID",
  "name": "$AGENT_NAME",
  "emoji": "$AGENT_EMOJI",
  "workspace": "$WORKSPACE",
  "task": $(echo "$TASK" | jq -Rs .),
  "messageId": "$MESSAGE_ID",
  "channel": "$CHANNEL"
}
EOF
