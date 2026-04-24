# OpenClaw Deployment Guide

**Quick reference for deploying and managing OpenClaw infrastructure.**

---

## 🚀 Quick Deploy

### **Prerequisites**

```bash
# Set Azure credentials
export ARM_CLIENT_ID="f2410d10-07d1-49e2-af61-dba86cc9b441"
export ARM_CLIENT_SECRET="your-secret"
export ARM_TENANT_ID="1b9184b9-e785-4727-a33d-f9526fe07006"
export ARM_SUBSCRIPTION_ID="05a43f56-f126-4bf1-bb97-9ca4d91dfcb5"
```

---

## 📦 Deploy Commands

### **Development VM (Quickest)**

```bash
# Plan (preview changes)
./deploy.sh dev vm plan

# Apply (deploy)
./deploy.sh dev vm apply

# Destroy (cleanup)
./deploy.sh dev vm destroy
```

**Cost:** ~$0.44/day ($13.50/month with auto-shutdown)

---

### **Staging ACI (Serverless)**

```bash
# Plan
./deploy.sh staging aci plan

# Apply
./deploy.sh staging aci apply

# Destroy
./deploy.sh staging aci destroy
```

**Cost:** ~$0.40/day ($12/month)

---

### **Production AKS (Scalable)**

```bash
# Plan (requires confirmation)
./deploy.sh production aks plan

# Apply (requires typing "DEPLOY")
./deploy.sh production aks apply

# Destroy (requires typing "DELETE")
./deploy.sh production aks destroy
```

**Cost:** ~$4.31/day ($132/month for 3 nodes)

---

### **Deploy Everything**

```bash
# Plan all resources
./deploy.sh production all plan

# Deploy all resources
./deploy.sh production all apply

# Destroy all resources
./deploy.sh production all destroy
```

**Cost:** ~$5.75/day ($172.50/month)

---

## 🔧 Manual Terraform

If you prefer direct Terraform commands:

```bash
# Navigate to environment
cd terraform/environments/dev

# Initialize
~/bin/terraform init

# Plan specific module
~/bin/terraform plan -target=module.openclaw_vm

# Apply
~/bin/terraform apply -target=module.openclaw_vm

# Destroy
~/bin/terraform destroy -target=module.openclaw_vm

# Show outputs
~/bin/terraform output
```

---

## ⚡ Safety Features

### **Confirmation Prompts**

- **Dev/Staging apply:** "yes" confirmation
- **Production apply:** Type "DEPLOY"
- **Any destroy:** Type "DELETE"

### **Cost Estimates**

Script shows estimated costs before deployment.

### **Logging**

All deployments logged to `deployments.log`:
```
[2026-04-24 21:15:00 UTC] apply: dev/vm
[2026-04-24 21:20:00 UTC] destroy: dev/vm
```

### **Prerequisites Check**

- ✅ Terraform binary exists
- ✅ Azure credentials set
- ✅ Valid inputs

---

## 📊 Cost Summary

| Environment | Platform | Action | Daily Cost | Monthly Cost |
|-------------|----------|--------|------------|--------------|
| Dev | VM (B1s) | Running | $0.44 | $13.50 |
| Dev | VM (B1s) | Stopped | $0.10 | $3.00 |
| Staging | ACI | Running | $0.40 | $12.00 |
| Production | AKS | Running | $4.31 | $132.00 |
| All | All + Backup + Monitor | Running | $5.75 | $172.50 |

---

## 🔍 Check Deployment Status

### **Azure Portal**

```bash
# Get resource group URL
~/bin/terraform output resource_group_url

# Or visit directly
open https://portal.azure.com/#@/resource/subscriptions/05a43f56.../resourceGroups/openclaw-dev-rg
```

### **Health Check**

```bash
# After VM deployment
VM_IP=$(~/bin/terraform output -raw public_ip_address)
curl http://${VM_IP}:3000/health

# After ACI deployment
ACI_FQDN=$(~/bin/terraform output -raw fqdn)
curl http://${ACI_FQDN}/health

# After AKS deployment
kubectl get pods -n openclaw-production
kubectl get svc -n openclaw-production
```

---

## 🆘 Troubleshooting

### **Deployment Fails**

```bash
# Check Terraform logs
~/bin/terraform plan -out=plan.tfplan
~/bin/terraform show plan.tfplan

# Check Azure provider
~/bin/terraform providers

# Refresh state
~/bin/terraform refresh
```

### **Destroy Fails**

```bash
# Force destroy
~/bin/terraform destroy -auto-approve

# Target specific resource
~/bin/terraform destroy -target=module.openclaw_vm.azurerm_linux_virtual_machine.openclaw

# Clear state (last resort)
~/bin/terraform state list
~/bin/terraform state rm <resource>
```

### **Can't SSH to VM**

```bash
# Check NSG rules
az network nsg rule list \
  --resource-group openclaw-dev-rg \
  --nsg-name openclaw-dev-nsg

# Get public IP
az vm list-ip-addresses \
  --resource-group openclaw-dev-rg \
  --name openclaw-dev-vm
```

---

## 📝 Examples

### **Test VM for 1 Hour**

```bash
# Deploy
./deploy.sh dev vm apply

# Test
VM_IP=$(cd terraform/environments/dev && ~/bin/terraform output -raw public_ip_address)
curl http://${VM_IP}:3000/health

# Cleanup after testing
./deploy.sh dev vm destroy
```

**Cost:** ~$0.02 (1 hour)

---

### **Weekend Testing (Friday-Monday)**

```bash
# Friday evening
./deploy.sh dev vm apply

# Monday morning
./deploy.sh dev vm destroy
```

**Cost:** ~$1.32 (3 days)

---

### **Full Week Test**

```bash
# Deploy all platforms
./deploy.sh dev vm apply
./deploy.sh staging aci apply

# Test for 1 week
# ...

# Cleanup
./deploy.sh dev vm destroy
./deploy.sh staging aci destroy
```

**Cost:** ~$5.88 (7 days, VM+ACI)

---

## 🎯 Recommended Workflow

### **First-Time Deployment**

1. **Plan first** (always)
   ```bash
   ./deploy.sh dev vm plan
   ```

2. **Review outputs** (check for errors)

3. **Deploy**
   ```bash
   ./deploy.sh dev vm apply
   ```

4. **Verify health**
   ```bash
   VM_IP=$(cd terraform/environments/dev && ~/bin/terraform output -raw public_ip_address)
   curl http://${VM_IP}:3000/health
   ```

5. **Test your application**

6. **Destroy if temporary**
   ```bash
   ./deploy.sh dev vm destroy
   ```

---

### **Production Deployment**

1. **Test in dev first**
2. **Test in staging**
3. **Plan production**
   ```bash
   ./deploy.sh production aks plan
   ```
4. **Get approval** (from team/manager)
5. **Deploy production**
   ```bash
   ./deploy.sh production aks apply
   ```
6. **Monitor closely** (first 24 hours)
7. **Document** (save outputs, IPs, URLs)

---

## 📚 Additional Resources

- [Terraform Modules](terraform/README.md)
- [Backstage Setup](backstage/README.md)
- [GitOps Guide](gitops/README.md)
- [Project Status](PROJECT_STATUS.md)

---

**Questions? Issues?**

- GitHub: https://github.com/appOrb/openClaw/issues
- Discord: #general
- Documentation: [docs.openclaw.ai](https://docs.openclaw.ai)
