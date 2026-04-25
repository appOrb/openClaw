#!/bin/bash

# GitHub Sync Script - Continuously update appOrb repositories
# Usage: ./github-sync.sh <repo> <file> <commit-message>

set -e

REPO=$1
FILE=$2
MESSAGE=$3

if [ -z "$REPO" ] || [ -z "$FILE" ] || [ -z "$MESSAGE" ]; then
    echo "Usage: $0 <repo> <file> <commit-message>"
    exit 1
fi

REPO_PATH="/home/azureuser/projects/appOrb/$REPO"

if [ ! -d "$REPO_PATH" ]; then
    echo "❌ Repo not found: $REPO_PATH"
    exit 1
fi

cd "$REPO_PATH"

# Pull latest changes
git pull origin main --rebase 2>/dev/null || true

# Add the file
git add "$FILE"

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "ℹ️  No changes to commit in $REPO/$FILE"
    exit 0
fi

# Commit with timestamp
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")
git commit -m "$MESSAGE" -m "Auto-committed: $TIMESTAMP"

# Push to GitHub
git push origin main

echo "✅ Pushed to $REPO: $FILE"
echo "   Message: $MESSAGE"
