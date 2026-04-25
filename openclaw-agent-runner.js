const { Client, GatewayIntentBits } = require('discord.js');
const { exec } = require('child_process');
const { promisify } = require('util');
const fs = require('fs');

const execAsync = promisify(exec);

const TOKENS_FILE = '/home/azureuser/projects/appOrb/openClaw/openclaw/config/bot-tokens.json';
const PERSONAS_FILE = '/home/azureuser/projects/appOrb/openClaw/openclaw/config/agent-personas.json';

const tokensData = JSON.parse(fs.readFileSync(TOKENS_FILE, 'utf8'));
const personasData = JSON.parse(fs.readFileSync(PERSONAS_FILE, 'utf8'));

// Map persona config ID → openclaw registered agent name
const AGENT_NAMES = {
  'diana-ceo': 'Diana CEO',
  'marcus-cto': 'Marcus CTO',
  'priya-cfo': 'Priya CFO',
  'leo-cmo': 'Leo CMO',
  'coo': 'COO',
  'alex-developer': 'Alex Developer',
  'morgan-architect': 'Morgan Architect',
  'sam-devsecops': 'Sam DevSecOps',
  'jordan-platform': 'Jordan Platform',
  'sage-infrastructure': 'Sage Infrastructure',
};

// Track sessions per agent+channel for multi-turn conversations
const sessions = new Map();

function getSessionKey(agentId, channelId) {
  return `${agentId}::${channelId}`;
}

function splitMessage(text, maxLen = 1950) {
  const chunks = [];
  while (text.length > maxLen) {
    let idx = text.lastIndexOf('\n', maxLen);
    if (idx < 100) idx = maxLen;
    chunks.push(text.slice(0, idx));
    text = text.slice(idx).trimStart();
  }
  if (text) chunks.push(text);
  return chunks;
}

async function callAgent(agentName, agentId, channelId, message) {
  const sessionKey = getSessionKey(agentId, channelId);
  const sessionId = sessions.get(sessionKey);

  let cmd = `openclaw agent --agent ${JSON.stringify(agentName)} --message ${JSON.stringify(message)} --json`;
  if (sessionId) cmd += ` --session-id ${sessionId}`;

  try {
    const { stdout, stderr } = await execAsync(cmd, { timeout: 120000 });
    const result = JSON.parse(stdout);
    const newSessionId = result.meta?.agentMeta?.sessionId;
    if (newSessionId) sessions.set(sessionKey, newSessionId);
    return result.payloads?.[0]?.text || null;
  } catch (err) {
    // If session expired, clear it and retry fresh
    if (err.message.includes('session') && sessionId) {
      sessions.delete(sessionKey);
      const { stdout } = await execAsync(
        `openclaw agent --agent ${JSON.stringify(agentName)} --message ${JSON.stringify(message)} --json`,
        { timeout: 120000 }
      );
      const result = JSON.parse(stdout);
      const newSessionId = result.meta?.agentMeta?.sessionId;
      if (newSessionId) sessions.set(sessionKey, newSessionId);
      return result.payloads?.[0]?.text || null;
    }
    throw err;
  }
}

function startBot(agentId) {
  const agentName = AGENT_NAMES[agentId];
  const token = tokensData.tokens[agentId];
  const persona = personasData.personas[agentId];

  if (!token || !persona || !agentName) {
    console.error(`[${agentId}] Missing token, persona, or agent name — skipping`);
    return;
  }

  const client = new Client({
    intents: [
      GatewayIntentBits.Guilds,
      GatewayIntentBits.GuildMessages,
      GatewayIntentBits.MessageContent,
    ]
  });

  client.once('ready', () => {
    console.log(`✅ ${persona.avatar_emoji} ${agentName} online as ${client.user.tag}`);
  });

  client.on('messageCreate', async (message) => {
    if (message.author.bot) return;

    // Channel access check
    if (persona.channels && persona.channels.length > 0) {
      if (!persona.channels.includes(message.channel.name)) return;
    }

    const isMentioned = message.mentions.users.has(client.user.id);
    const content = message.content.toLowerCase();
    const isKeywordMatch = (persona.triggers || []).some(t => content.includes(t.toLowerCase()));

    if (!isMentioned && !isKeywordMatch && !persona.auto_respond) return;

    // Show typing indicator
    await message.channel.sendTyping().catch(() => {});

    const cleanMsg = message.content.replace(/<@!?\d+>/g, '').trim() || 'Hello';
    const context = `[Discord #${message.channel.name}, user: ${message.author.username}]\n${cleanMsg}`;

    console.log(`📨 [${agentName}] #${message.channel.name} → ${message.author.username}: ${cleanMsg.substring(0, 60)}`);

    try {
      const reply = await callAgent(agentName, agentId, message.channel.id, context);
      if (!reply) {
        await message.reply(`${persona.avatar_emoji} I processed your message but have nothing to add right now.`);
        return;
      }
      const chunks = splitMessage(reply);
      await message.reply(chunks[0]);
      for (let i = 1; i < chunks.length; i++) {
        await message.channel.send(chunks[i]);
      }
      console.log(`✅ [${agentName}] Replied (${reply.length} chars)`);
    } catch (err) {
      console.error(`❌ [${agentName}] Error:`, err.message?.substring(0, 100));
      await message.reply(`${persona.avatar_emoji} I'm having trouble responding right now. Please try again in a moment.`);
    }
  });

  client.on('error', (err) => {
    console.error(`[${agentName}] Discord client error:`, err.message);
  });

  client.login(token).catch(err => {
    console.error(`[${agentName}] Login failed:`, err.message);
  });
}

console.log('🚀 Starting OpenClaw multi-agent Discord runner...');
for (const agentId of Object.keys(AGENT_NAMES)) {
  startBot(agentId);
}
