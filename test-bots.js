const { Client, GatewayIntentBits } = require('discord.js');
const fs = require('fs');

const tokensPath = '/home/azureuser/projects/appOrb/openClaw/openclaw/config/bot-tokens.json';
const tokens = JSON.parse(fs.readFileSync(tokensPath, 'utf8'));

console.log('Testing bot connections...\n');

const agentIds = [
  'diana-ceo',
  'marcus-cto', 
  'priya-cfo',
  'leo-cmo',
  'coo',
  'alex-developer',
  'morgan-architect',
  'sam-devsecops',
  'jordan-platform',
  'sage-infrastructure'
];

let connectedCount = 0;

agentIds.forEach(agentId => {
  const token = tokens.tokens[agentId];
  
  if (!token || token === 'YOUR_BOT_TOKEN_HERE') {
    console.log(`❌ ${agentId}: No token configured`);
    return;
  }

  const client = new Client({
    intents: [
      GatewayIntentBits.Guilds,
      GatewayIntentBits.GuildMessages,
      GatewayIntentBits.MessageContent
    ]
  });

  client.once('ready', () => {
    connectedCount++;
    console.log(`✅ ${agentId}: Connected as ${client.user.tag}`);
    
    const guild = client.guilds.cache.first();
    if (guild) {
      const channels = guild.channels.cache.filter(c => c.type === 0);
      console.log(`   Guild: ${guild.name}`);
      console.log(`   Visible channels: ${channels.size}`);
    }
    
    if (connectedCount === agentIds.length) {
      console.log(`\n✅ All ${connectedCount} bots connected successfully!`);
      process.exit(0);
    }
  });

  client.on('error', error => {
    console.log(`❌ ${agentId}: Error - ${error.message}`);
  });

  client.login(token).catch(error => {
    console.log(`❌ ${agentId}: Login failed - ${error.message}`);
  });
});

setTimeout(() => {
  console.log(`\n⚠️  Timeout: ${connectedCount}/${agentIds.length} bots connected`);
  process.exit(1);
}, 15000);
