#!/bin/bash
cd /home/azureuser/projects/appOrb/openClaw
exec node openclaw/discord-agent-handler.js "$@"
