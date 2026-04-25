const { Client, GatewayIntentBits } = require('discord.js');
const fs = require('fs');

const tokensPath = '/home/azureuser/projects/appOrb/openClaw/openclaw/config/bot-tokens.json';
const tokens = JSON.parse(fs.readFileSync(tokensPath, 'utf8'));

const GUILD_ID = '1496046200007299122';

async function checkBotAccess(agentId) {
  const token = tokens.tokens[agentId];
  if (!token || token === 'YOUR_BOT_TOKEN_HERE') return;

  const client = new Client({
    intents: [
      GatewayIntentBits.Guilds,
      GatewayIntentBits.GuildMessages,
      GatewayIntentBits.MessageContent
    ]
  });

  return new Promise((resolve) => {
    client.once('ready', async () => {
      const guild = client.guilds.cache.get(GUILD_ID);
      if (!guild) {
        console.log(`❌ ${agentId}: Cannot access guild`);
        client.destroy();
        resolve();
        return;
      }

      const textChannels = guild.channels.cache.filter(c => c.type === 0);
      console.log(`✅ ${agentId}: Can see ${textChannels.size} channels`);
      
      if (textChannels.size < 21) {
        console.log(`   ⚠️  Expected 21 channels, only seeing ${textChannels.size}`);
        console.log(`   Visible: ${textChannels.map(c => c.name).join(', ')}`);
      }
      
      client.destroy();
      resolve();
    });

    client.login(token).catch(error => {
      console.log(`❌ ${agentId}: ${error.message}`);
      resolve();
    });
  });
}

const agentIds = [
  'diana-ceo', 'marcus-cto', 'priya-cfo', 'leo-cmo', 'coo',
  'alex-developer', 'morgan-architect', 'sam-devsecops', 
  'jordan-platform', 'sage-infrastructure'
];

(async () => {
  console.log('Checking bot channel access...\n');
  for (const agentId of agentIds) {
    await checkBotAccess(agentId);
  }
  console.log('\nAccess check complete!');
  process.exit(0);
})();
