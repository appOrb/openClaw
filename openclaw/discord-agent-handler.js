#!/usr/bin/env node
/**
 * Discord Agent Handler - Bridges Discord messages to multi-agent router
 * 
 * This module:
 * 1. Receives Discord message metadata
 * 2. Routes to appropriate agent(s) via agent-router.js
 * 3. Spawns OpenClaw sessions with agent personas
 * 4. Handles response delivery via Discord webhooks
 */

const { execSync } = require('child_process');
const path = require('path');

const ROUTER_PATH = path.join(__dirname, 'agent-router.js');
const SPAWN_PATH = path.join(__dirname, 'agent-spawn.sh');

/**
 * Process incoming Discord message and route to agents
 * @param {Object} envelope - Discord message envelope
 * @returns {Promise<Array>} Array of spawned agent sessions
 */
async function handleMessage(envelope) {
  const { body, channel, sender, messageId } = envelope;
  
  console.log(`[Discord Agent Handler] Processing message: ${body}`);
  
  try {
    // Step 1: Route message to appropriate agents
    const routeCmd = `node ${ROUTER_PATH} route "${body}" ${channel} ${sender.id}`;
    const routingResult = execSync(routeCmd, { encoding: 'utf8' });
    const agents = JSON.parse(routingResult);
    
    if (agents.length === 0) {
      console.log('[Discord Agent Handler] No agents matched');
      return [];
    }
    
    console.log(`[Discord Agent Handler] Routing to ${agents.length} agent(s):`, 
                agents.map(a => a.agentId).join(', '));
    
    // Step 2: Spawn agent sessions
    const sessions = [];
    for (const agent of agents) {
      try {
        const spawnCmd = `${SPAWN_PATH} ${agent.agentId} "${body}" ${channel} ${sender.id} ${messageId}`;
        const result = execSync(spawnCmd, { encoding: 'utf8', timeout: 5000 });
        
        sessions.push({
          agentId: agent.agentId,
          status: 'spawned',
          output: result.trim()
        });
        
        console.log(`[Discord Agent Handler] ✓ Spawned ${agent.agentId}`);
      } catch (spawnError) {
        console.error(`[Discord Agent Handler] ✗ Failed to spawn ${agent.agentId}:`, spawnError.message);
        sessions.push({
          agentId: agent.agentId,
          status: 'error',
          error: spawnError.message
        });
      }
    }
    
    return sessions;
    
  } catch (error) {
    console.error('[Discord Agent Handler] Routing error:', error.message);
    throw error;
  }
}

/**
 * CLI entry point for testing
 */
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length < 3) {
    console.log('Usage: node discord-agent-handler.js <message> <channel> <senderId> [messageId]');
    process.exit(1);
  }
  
  const [body, channel, senderId, messageId = 'test-msg'] = args;
  
  const envelope = {
    body,
    channel,
    sender: { id: senderId },
    messageId
  };
  
  handleMessage(envelope)
    .then(sessions => {
      console.log('\n[Result]', JSON.stringify(sessions, null, 2));
    })
    .catch(error => {
      console.error('[Error]', error.message);
      process.exit(1);
    });
}

module.exports = { handleMessage };
