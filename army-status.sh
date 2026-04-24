#!/bin/bash
# Check OpenClaw Army Status

TERRAFORM_BIN="${HOME}/bin/terraform"
ARMY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/army-deployment"

if [ ! -d "$ARMY_DIR" ]; then
    echo "❌ Army not deployed yet"
    exit 1
fi

cd "$ARMY_DIR"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║         OpenClaw Army Status                             ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Get VM IPs
echo "VM Addresses:"
$TERRAFORM_BIN output -json vm_ips 2>/dev/null | python3 -m json.tool

echo ""
echo "Checking VM Health:"

# Parse IPs and check each
IPS=$($TERRAFORM_BIN output -json vm_ips 2>/dev/null | python3 -c "import sys,json; print(' '.join(json.load(sys.stdin).values()))")

for IP in $IPS; do
    echo -n "  $IP: "
    if timeout 5 bash -c "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 azureuser@$IP 'echo ok' 2>/dev/null" > /dev/null; then
        echo "✅ SSH OK"
        ssh -o StrictHostKeyChecking=no azureuser@$IP 'systemctl is-active openclaw 2>/dev/null || echo "⚠️  OpenClaw not running"'
    else
        echo "⚠️  SSH not ready yet (bootstrapping...)"
    fi
done

echo ""
echo "Azure Portal:"
echo "  https://portal.azure.com/#@/resource/subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/openclaw-army-rg"
