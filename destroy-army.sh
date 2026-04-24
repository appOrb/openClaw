#!/bin/bash
# Destroy OpenClaw Army

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TERRAFORM_BIN="${HOME}/bin/terraform"
ARMY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/army-deployment"

if [ ! -d "$ARMY_DIR" ]; then
    echo "❌ Army not deployed"
    exit 1
fi

echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║         OpenClaw Army Destruction                        ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${RED}⚠️  WARNING: This will DELETE all army VMs and resources!${NC}"
echo ""

cd "$ARMY_DIR"

# Show what will be destroyed
VM_COUNT=$($TERRAFORM_BIN output -json vm_ips 2>/dev/null | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" || echo "unknown")

echo "Will destroy:"
echo "  - $VM_COUNT VMs"
echo "  - All network resources"
echo "  - Resource group: openclaw-army-rg"
echo ""

read -p "Type 'DELETE' to confirm: " confirm

if [ "$confirm" != "DELETE" ]; then
    echo "Cancelled"
    exit 0
fi

echo ""
echo "Destroying army..."
$TERRAFORM_BIN destroy -auto-approve

echo ""
echo -e "${GREEN}✅ Army destroyed!${NC}"

# Clean up directory
cd ..
rm -rf "$ARMY_DIR"

echo "✅ Cleanup complete"
