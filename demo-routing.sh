#!/bin/bash
# Demonstration of multi-agent routing system

ROUTER="/home/azureuser/projects/appOrb/openClaw/openclaw/agent-router.js"

echo "=== Multi-Agent Discord Routing Demonstration ==="
echo ""

echo "Test 1: Direct @mention"
echo "Message: '@alex-developer can you fix the login bug?'"
echo "Channel: dev-team"
echo "---"
node "$ROUTER" route "@alex-developer can you fix the login bug?" "dev-team" "user123"
echo ""

echo "Test 2: Keyword trigger (security)"
echo "Message: 'We have a security vulnerability in production'"
echo "Channel: security"
echo "---"
node "$ROUTER" route "We have a security vulnerability in production" "security" "user123"
echo ""

echo "Test 3: Multiple agents"
echo "Message: '@marcus-cto @alex-developer need architecture review'"
echo "Channel: engineering-all"
echo "---"
node "$ROUTER" route "@marcus-cto @alex-developer need architecture review" "engineering-all" "user123"
echo ""

echo "Test 4: Channel access control (should fail)"
echo "Message: '@alex-developer help with budget'"
echo "Channel: financial-ops"
echo "---"
node "$ROUTER" route "@alex-developer help with budget" "financial-ops" "user123"
echo ""

echo "Test 5: Get agents for channel"
echo "Channel: dev-team"
echo "---"
node "$ROUTER" channel-agents "dev-team"
echo ""

echo "=== Demonstration Complete ==="
