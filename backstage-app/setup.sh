#!/bin/bash
# Backstage Setup Script

set -e

echo "╔══════════════════════════════════════════════════════════╗"
echo "║         OpenClaw Backstage Setup                         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Check Node.js
echo "Checking Node.js version..."
NODE_VERSION=$(node --version 2>/dev/null || echo "not found")
if [[ "$NODE_VERSION" == "not found" ]]; then
    echo "❌ Node.js not found. Please install Node.js 20 or 22."
    exit 1
fi
echo "✅ Node.js version: $NODE_VERSION"
echo ""

# Check yarn
echo "Checking yarn..."
if ! command -v yarn &> /dev/null; then
    echo "⚠️  yarn not found. Installing yarn..."
    npm install -g yarn
fi
echo "✅ yarn version: $(yarn --version)"
echo ""

# Install dependencies
echo "Installing dependencies..."
echo "⚠️  This may take 5-10 minutes on first run..."
yarn install

echo ""
echo "✅ Backstage setup complete!"
echo ""
echo "Next steps:"
echo "1. Copy .env.example to .env"
echo "2. Fill in your credentials"
echo "3. Run: yarn dev"
echo ""
echo "Access at: http://localhost:3000"
