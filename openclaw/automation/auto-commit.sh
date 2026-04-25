#!/bin/bash

# Auto-commit wrapper for common updates
# Simplifies pushing agent updates to GitHub

SYNC="/home/azureuser/projects/appOrb/openClaw/openclaw/automation/github-sync.sh"

# Function to commit and push agent registry
update_agent_registry() {
    $SYNC "company-operations" "agents/registry.json" "[Agent:System] Updated agent registry"
}

# Function to commit daily metrics
update_metrics() {
    DATE=$(date -u +"%Y-%m-%d")
    $SYNC "metrics-dashboard" "daily/$DATE.json" "[Metrics] Daily metrics update"
}

# Function to commit incident
log_incident() {
    INCIDENT_ID=$1
    $SYNC "incident-management" "incidents/$INCIDENT_ID.md" "[Incident:$INCIDENT_ID] Logged incident"
}

# Function to commit agent workflow
update_workflow() {
    AGENT=$1
    $SYNC "agent-workflows" "workflows/$AGENT.yaml" "[Agent:$AGENT] Updated workflow"
}

# Function to commit automation script
update_automation() {
    SCRIPT=$1
    $SYNC "automation-scripts" "scripts/$SCRIPT" "[Automation] Updated $SCRIPT"
}

# Main entry point
case "$1" in
    agent-registry)
        update_agent_registry
        ;;
    metrics)
        update_metrics
        ;;
    incident)
        log_incident "$2"
        ;;
    workflow)
        update_workflow "$2"
        ;;
    automation)
        update_automation "$2"
        ;;
    *)
        echo "Usage: $0 {agent-registry|metrics|incident|workflow|automation} [args]"
        exit 1
        ;;
esac
