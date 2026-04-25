#!/usr/bin/env node
/**
 * Agent Routing System for Discord Multi-Agent Operations
 * Routes @mentions and keywords to appropriate agent workspaces
 */

const fs = require('fs');
const path = require('path');

// Load configurations
const PERSONAS_PATH = '/home/azureuser/projects/appOrb/openClaw/openclaw/config/agent-personas.json';
const AGENTS_PATH = '/home/azureuser/projects/appOrb/openClaw/openclaw/config/agents.json';

class AgentRouter {
  constructor() {
    this.personas = JSON.parse(fs.readFileSync(PERSONAS_PATH, 'utf8')).personas;
    this.agents = JSON.parse(fs.readFileSync(AGENTS_PATH, 'utf8')).agents;
    this.routing = JSON.parse(fs.readFileSync(PERSONAS_PATH, 'utf8')).routing;
    this.activeAgents = new Map();
  }

  /**
   * Parse message for agent mentions and keywords
   */
  parseMessage(message, channel) {
    const matches = [];
    
    // Check for direct @mentions
    const mentionRegex = new RegExp(this.routing.mention_pattern, 'gi');
    const mentions = message.match(mentionRegex);
    
    if (mentions) {
      mentions.forEach(mention => {
        const handle = mention.slice(1); // Remove @
        const agent = this.findAgentByHandle(handle);
        if (agent && this.canAccessChannel(agent, channel)) {
          matches.push({
            type: 'mention',
            agent: agent,
            priority: this.personas[agent].priority,
            confidence: 1.0
          });
        }
      });
    }

    // Check for keyword triggers
    const lowerMessage = message.toLowerCase();
    Object.entries(this.personas).forEach(([agentId, persona]) => {
      if (!this.canAccessChannel(agentId, channel)) return;
      
      persona.triggers.forEach(trigger => {
        if (lowerMessage.includes(trigger.toLowerCase())) {
          matches.push({
            type: 'keyword',
            agent: agentId,
            priority: persona.priority,
            confidence: 0.7,
            trigger: trigger
          });
        }
      });
    });

    // Sort by priority and confidence
    return matches.sort((a, b) => {
      const priorityOrder = { critical: 0, high: 1, medium: 2, low: 3 };
      const priorityDiff = priorityOrder[a.priority] - priorityOrder[b.priority];
      if (priorityDiff !== 0) return priorityDiff;
      return b.confidence - a.confidence;
    });
  }

  /**
   * Find agent by Discord handle
   */
  findAgentByHandle(handle) {
    for (const [agentId, persona] of Object.entries(this.personas)) {
      if (persona.discord_handle === handle) {
        return agentId;
      }
    }
    return null;
  }

  /**
   * Check if agent can access channel
   */
  canAccessChannel(agentId, channel) {
    const persona = this.personas[agentId];
    if (!persona) return false;
    return persona.channels.includes(channel);
  }

  /**
   * Get agent workspace path
   */
  getAgentWorkspace(agentId) {
    const agent = this.agents.find(a => a.id === agentId);
    return agent ? agent.workspace : null;
  }

  /**
   * Get agent display info for webhook
   */
  getAgentDisplayInfo(agentId) {
    const persona = this.personas[agentId];
    if (!persona) return null;
    
    return {
      username: persona.name,
      avatar: persona.avatar_emoji,
      color: parseInt(persona.color.slice(1), 16)
    };
  }

  /**
   * Check if agent should auto-respond
   */
  shouldAutoRespond(agentId) {
    const persona = this.personas[agentId];
    return persona ? persona.auto_respond : false;
  }

  /**
   * Route message to agent(s)
   * Returns list of agents to spawn
   */
  route(message, channel, senderId) {
    const matches = this.parseMessage(message, channel);
    
    // Limit concurrent agents
    const maxConcurrent = this.routing.max_concurrent_agents;
    const toSpawn = [];

    for (const match of matches) {
      // Skip if already active and not a direct mention
      if (match.type !== 'mention' && this.activeAgents.has(match.agent)) {
        continue;
      }

      // Only auto-respond agents or direct mentions
      if (match.type === 'mention' || this.shouldAutoRespond(match.agent)) {
        toSpawn.push({
          agentId: match.agent,
          workspace: this.getAgentWorkspace(match.agent),
          displayInfo: this.getAgentDisplayInfo(match.agent),
          priority: match.priority,
          context: {
            channel: channel,
            senderId: senderId,
            message: message,
            trigger: match.trigger || 'mention'
          }
        });

        // Mark as active
        this.activeAgents.set(match.agent, Date.now());
      }

      if (toSpawn.length >= maxConcurrent) break;
    }

    // Cleanup old active agents (after timeout)
    const timeout = this.routing.response_timeout_seconds * 1000;
    const now = Date.now();
    for (const [agentId, timestamp] of this.activeAgents.entries()) {
      if (now - timestamp > timeout) {
        this.activeAgents.delete(agentId);
      }
    }

    return toSpawn;
  }

  /**
   * Get all agents for a channel
   */
  getChannelAgents(channel) {
    return Object.entries(this.personas)
      .filter(([_, persona]) => persona.channels.includes(channel))
      .map(([agentId, persona]) => ({
        id: agentId,
        name: persona.name,
        handle: persona.discord_handle,
        autoRespond: persona.auto_respond
      }));
  }

  /**
   * Get agent info
   */
  getAgentInfo(agentId) {
    const persona = this.personas[agentId];
    const agent = this.agents.find(a => a.id === agentId);
    
    if (!persona || !agent) return null;
    
    return {
      ...persona,
      ...agent
    };
  }
}

// CLI interface
if (require.main === module) {
  const router = new AgentRouter();
  const command = process.argv[2];

  switch (command) {
    case 'route':
      const message = process.argv[3];
      const channel = process.argv[4];
      const senderId = process.argv[5] || 'unknown';
      const result = router.route(message, channel, senderId);
      console.log(JSON.stringify(result, null, 2));
      break;

    case 'channel-agents':
      const channelName = process.argv[3];
      const agents = router.getChannelAgents(channelName);
      console.log(JSON.stringify(agents, null, 2));
      break;

    case 'agent-info':
      const agentId = process.argv[3];
      const info = router.getAgentInfo(agentId);
      console.log(JSON.stringify(info, null, 2));
      break;

    default:
      console.log('Usage:');
      console.log('  node agent-router.js route "<message>" <channel> [senderId]');
      console.log('  node agent-router.js channel-agents <channel>');
      console.log('  node agent-router.js agent-info <agentId>');
  }
}

module.exports = AgentRouter;
