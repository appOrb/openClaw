const { Client, GatewayIntentBits } = require("discord.js");
const fs = require("fs");
const agentId = process.argv[2];
if (!agentId) { console.error("Usage: node simple-bot.js <agent-id>"); process.exit(1); }
const tokens = JSON.parse(fs.readFileSync("/home/azureuser/projects/appOrb/openClaw/openclaw/config/bot-tokens.json", "utf8"));
const personas = JSON.parse(fs.readFileSync("/home/azureuser/projects/appOrb/openClaw/openclaw/config/agent-personas.json", "utf8")).personas;
const token = tokens.tokens[agentId];
const persona = personas[agentId];
if (!token || !persona) { console.error(`Agent ${agentId} not found`); process.exit(1); }
const client = new Client({ intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages, GatewayIntentBits.MessageContent] });
client.once("ready", () => {
  console.log(`✅ ${persona.name} is online!`);
  console.log(`   ID: ${client.user.id}`);
  console.log(`   Channels: ${persona.channels.join(", ")}`);
});
client.on("messageCreate", async message => {
  if (message.author.bot) return;
  if (!persona.channels.includes(message.channel.name)) return;
  const isDirectMention = message.mentions.users.has(client.user.id);
  const isTextMention = message.content.toLowerCase().includes(persona.discord_handle);
  if (!isDirectMention && !isTextMention && !persona.auto_respond) return;
  console.log(`📨 [${message.channel.name}] ${message.author.username}: ${message.content.substring(0, 50)}`);
  await message.reply(`${persona.avatar_emoji} Hello! I am ${persona.name}. I am here and ready to help.`);
});
client.login(token);
