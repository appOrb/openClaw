# OpenClaw Army - 2 VM Deployment Configuration

## Army Configuration
- **VMs:** 2
- **Environment:** dev
- **Region:** eastus
- **Agents per VM:** 9
- **Total Agents:** 18

## VM Details

### VM 1: openclaw-army-01
- Size: Standard_B2s
- OS: Ubuntu 22.04
- Agents: 9 (CEO, CMO, CTO, Engineer, DevOps, Platform, Infrastructure, Security, Researcher)

### VM 2: openclaw-army-02
- Size: Standard_B2s
- OS: Ubuntu 22.04
- Agents: 9 (same roles)

## Cost Estimate
- Per VM: $27/month ($0.88/day)
- Total: $54/month ($1.76/day)

## Network Configuration
- Virtual Network: openclaw-army-vnet (10.0.0.0/16)
- VM1 Subnet: 10.0.1.0/24
- VM2 Subnet: 10.0.2.0/24
- Public IPs: 2 (one per VM)

## Deployment Steps
1. Set Azure credentials
2. Run: ./deploy-army.sh 2
3. Wait for deployment (5-10 minutes)
4. Get VM IPs from outputs
5. SSH to each VM
6. Verify OpenClaw status

## Access
- VM1: ssh azureuser@<VM1_IP>
- VM2: ssh azureuser@<VM2_IP>

## Commands
```bash
# Deploy
./deploy-army.sh 2

# Check status
./army-status.sh

# Destroy
./destroy-army.sh
```
