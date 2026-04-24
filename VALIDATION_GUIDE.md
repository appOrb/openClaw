# OpenClaw Validation Guide

**Step-by-step validation using IDP (Backstage) and infrastructure deployment.**

---

## 🎯 Overview

This guide covers:
1. Infrastructure validation (Terraform)
2. IDP/Backstage validation
3. GitOps validation (ArgoCD)
4. End-to-end deployment test

**Estimated time:** 30-60 minutes

---

## ✅ Pre-Validation Checklist

Before starting, ensure you have:

- [ ] Azure credentials (Service Principal)
- [ ] GitHub Personal Access Token
- [ ] SSH key pair (for VM access)
- [ ] Node.js 20 or 22 installed
- [ ] Terraform binary (or run ./scripts/install-terraform.sh)

---

## 📋 Part 1: Infrastructure Validation (10 minutes)

### **Step 1.1: Run Validation Script**

```bash
cd /path/to/openClaw
./validate.sh
```

**Expected output:**
```
✅ Terraform found: Terraform v1.14.9
✅ All required directories present
✅ All required files exist
✅ Dev: terraform init succeeded
✅ Dev: terraform validate succeeded
✅ Staging: terraform init succeeded
✅ Staging: terraform validate succeeded
✅ Production: terraform init succeeded
✅ Production: terraform validate succeeded
✅ All modules valid

🎉 All tests passed! Infrastructure is ready for deployment.
```

**✅ Pass criteria:** All tests green, zero failures

---

### **Step 1.2: Terraform Plan (Dry Run)**

Test infrastructure without deploying:

```bash
# Set Azure credentials
export ARM_CLIENT_ID="f2410d10-07d1-49e2-af61-dba86cc9b441"
export ARM_CLIENT_SECRET="your-azure-secret"
export ARM_TENANT_ID="1b9184b9-e785-4727-a33d-f9526fe07006"
export ARM_SUBSCRIPTION_ID="05a43f56-f126-4bf1-bb97-9ca4d91dfcb5"

# Plan dev VM deployment
./deploy.sh dev vm plan
```

**Expected output:**
```
Plan: X to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + public_ip_address  = (known after apply)
  + ssh_connection     = (known after apply)
  + vm_id              = (known after apply)
```

**✅ Pass criteria:** 
- Plan succeeds without errors
- Resources to be created shown
- No unexpected changes

---

### **Step 1.3: Cost Estimate Verification**

Script should show cost before deployment:

```bash
./deploy.sh dev vm apply
```

**Expected output (before confirmation):**
```
ℹ️  Estimated monthly costs:
  VM (B1s): ~$13.50/month (~$0.44/day)

Continue? (yes/no):
```

**✅ Pass criteria:** Cost estimate displayed correctly

---

## 📋 Part 2: IDP/Backstage Validation (15 minutes)

### **Step 2.1: Install Backstage**

```bash
cd backstage-app

# Run automated setup
./setup.sh
```

**Expected output:**
```
✅ Node.js version: v20.x.x
✅ yarn version: 1.22.x
Installing dependencies...
✅ Backstage setup complete!

Next steps:
1. Copy .env.example to .env
2. Fill in your credentials
3. Run: yarn dev
```

**✅ Pass criteria:** 
- No errors during installation
- All dependencies installed
- Setup complete message shown

---

### **Step 2.2: Configure Environment**

```bash
# Copy environment template
cp .env.example .env

# Edit with your credentials
nano .env  # or vim, code, etc.
```

**Required minimum configuration:**
```bash
GITHUB_TOKEN=ghp_your_github_token
```

**Optional (for full features):**
```bash
AZURE_CLIENT_ID=f2410d10-...
AZURE_CLIENT_SECRET=your_secret
AUTH_GITHUB_CLIENT_ID=your_oauth_client
AUTH_GITHUB_CLIENT_SECRET=your_oauth_secret
```

**✅ Pass criteria:** .env file created with at least GITHUB_TOKEN

---

### **Step 2.3: Start Backstage**

```bash
yarn dev
```

**Expected output:**
```
[0] webpack compiled with 0 warnings
[0] 
[0] ╭───────────────────────────────────────────────────╮
[0] │                                                   │
[0] │   Backstage                                       │
[0] │                                                   │
[0] │   http://localhost:3000                           │
[0] │                                                   │
[0] ╰───────────────────────────────────────────────────╯

[1] Backend started on :7007
```

**✅ Pass criteria:**
- Frontend starts on port 3000
- Backend starts on port 7007
- No critical errors in console

---

### **Step 2.4: Verify IDP Access**

Open browser to: **http://localhost:3000**

**Expected:**
1. Backstage home page loads
2. Navigation bar visible (Catalog, Docs, Create, APIs)
3. No error messages

**✅ Pass criteria:** 
- Page loads successfully
- UI renders correctly
- Can navigate between pages

---

### **Step 2.5: Verify Software Catalog**

Navigate to **Catalog** page

**Expected to see:**
- System: `openclaw`
- Components:
  - openclaw-vm
  - openclaw-aci
  - openclaw-aks
  - openclaw-backup
  - openclaw-monitoring
  - openclaw-api (if configured)

**Click on any component:**
- Overview tab loads
- Relations shown
- API docs link (if applicable)

**✅ Pass criteria:**
- All 5+ components visible
- Component details page loads
- No broken links

---

### **Step 2.6: Verify Templates**

Navigate to **Create** page

**Expected to see:**
- Template: "Deploy New OpenClaw Instance"
- Description visible
- "Choose" button available

**Click "Choose":**
- Form loads with fields:
  - Instance Name
  - Environment (dev/staging/production)
  - Platform (VM/ACI/AKS)
  - Region
  - Agent Count

**✅ Pass criteria:**
- Template visible and clickable
- Form renders all fields
- Validation works (try invalid input)

---

### **Step 2.7: Test Template (Optional - Dry Run)**

Fill in template form:
- **Name:** test-openclaw
- **Environment:** dev
- **Platform:** vm
- **Region:** eastus
- **Agents:** 9

**Click "Review":**
- Summary page shows all inputs
- No validation errors

**Do NOT click "Create" yet** (unless you want to deploy)

**✅ Pass criteria:**
- Form submission works
- Validation passes
- Summary page renders

---

## 📋 Part 3: Infrastructure Deployment Test (15 minutes)

### **Step 3.1: Deploy VM to Dev**

**⚠️ This will incur Azure costs (~$0.44/day)**

```bash
# From project root
./deploy.sh dev vm apply
```

**Confirmation prompt:**
```
Environment: dev
Platform: vm
Action: apply

Continue? (yes/no):
```

Type: **yes**

**Expected progress:**
```
✅ Prerequisites check passed
✅ Input validation passed
ℹ️  Estimated monthly costs: ~$13.50/month

Running Terraform apply...
azurerm_resource_group.openclaw_dev: Creating...
azurerm_resource_group.openclaw_dev: Creation complete
azurerm_virtual_network.openclaw: Creating...
...
Apply complete! Resources: X added, 0 changed, 0 destroyed.

Outputs:
public_ip_address = "20.X.X.X"
vm_id = "/subscriptions/.../openclaw-dev-vm"
```

**✅ Pass criteria:**
- Deployment succeeds without errors
- Resources created in Azure
- Outputs show public IP

---

### **Step 3.2: Verify Azure Resources**

**Check in Azure Portal:**

1. Navigate to Resource Group: `openclaw-dev-rg`
2. Verify resources exist:
   - [ ] Virtual Machine: `openclaw-dev-vm`
   - [ ] Network Interface: `openclaw-dev-nic`
   - [ ] Public IP: `openclaw-dev-pip`
   - [ ] Virtual Network: `dev-openclaw-vnet`
   - [ ] Network Security Group: `dev-openclaw-nsg`

**Or via Azure CLI:**
```bash
az resource list --resource-group openclaw-dev-rg --output table
```

**✅ Pass criteria:**
- All resources visible in portal
- Resource group exists
- No deployment errors

---

### **Step 3.3: Test VM Access**

Get VM IP from Terraform output:
```bash
cd terraform/environments/dev
~/bin/terraform output public_ip_address
```

**SSH to VM:**
```bash
ssh azureuser@<public_ip>
```

**On VM, verify OpenClaw:**
```bash
# Check OpenClaw installation
openclaw status

# Check services
systemctl status openclaw

# Check logs
journalctl -u openclaw -n 50
```

**✅ Pass criteria:**
- SSH connection succeeds
- OpenClaw is installed
- Services are running (or installing)

---

### **Step 3.4: Test Health Endpoint**

```bash
curl http://<public_ip>:3000/health
```

**Expected response:**
```json
{
  "status": "ok",
  "version": "1.0.0",
  "timestamp": "2026-04-24T21:30:00Z"
}
```

**✅ Pass criteria:**
- Health endpoint responds
- Status is "ok"
- JSON format valid

---

### **Step 3.5: Cleanup (Destroy Resources)**

**⚠️ This will delete all resources**

```bash
./deploy.sh dev vm destroy
```

**Confirmation prompt:**
```
⚠️  WARNING: This will DELETE all resources!
Type 'DELETE' to confirm:
```

Type: **DELETE**

**Expected output:**
```
Running Terraform destroy...
azurerm_linux_virtual_machine.openclaw: Destroying...
azurerm_network_interface.openclaw: Destroying...
...
Destroy complete! Resources: X destroyed.
```

**Verify in Azure Portal:**
- Resource group should be empty or deleted
- No lingering resources

**✅ Pass criteria:**
- Destroy succeeds
- All resources deleted
- No errors

---

## 📋 Part 4: GitOps Validation (Optional - 10 minutes)

### **Step 4.1: Verify ArgoCD Configuration**

```bash
cd gitops/argocd
cat argocd-install.yaml
```

**Expected:**
- Valid Kubernetes YAML
- Namespace: argocd
- ServiceAccount configured
- RBAC policies defined

**✅ Pass criteria:** YAML is valid and complete

---

### **Step 4.2: Verify Application Manifests**

```bash
cd gitops/apps
cat openclaw.yaml
```

**Expected:**
- 3 Applications defined:
  - openclaw-dev
  - openclaw-staging
  - openclaw-production
- Sync policies configured
- Source repo correct

**✅ Pass criteria:** All applications defined correctly

---

### **Step 4.3: (If AKS available) Deploy ArgoCD**

**Skip if no AKS cluster**

```bash
kubectl create namespace argocd
kubectl apply -f gitops/argocd/argocd-install.yaml
```

**Verify:**
```bash
kubectl get pods -n argocd
```

**Expected:**
```
NAME                                  READY   STATUS    RESTARTS   AGE
argocd-server-xxx                     1/1     Running   0          2m
```

**✅ Pass criteria:**
- Pods running
- No errors

---

## 📋 Part 5: End-to-End Validation Summary

### **Validation Checklist:**

**Infrastructure:**
- [ ] validate.sh passes all tests
- [ ] Terraform plan succeeds
- [ ] Cost estimates display correctly
- [ ] VM deployment succeeds
- [ ] Azure resources created
- [ ] SSH access works
- [ ] Health endpoint responds
- [ ] Destroy succeeds

**IDP/Backstage:**
- [ ] Installation completes
- [ ] Environment configured
- [ ] Dev server starts
- [ ] UI accessible at localhost:3000
- [ ] Software catalog loads
- [ ] Components visible (5+)
- [ ] Templates page works
- [ ] Form validation works

**GitOps:**
- [ ] ArgoCD config valid
- [ ] Application manifests valid
- [ ] (Optional) ArgoCD deploys to AKS

---

## 📊 Validation Report Template

After completing all tests, fill this report:

```
OPENCLAW VALIDATION REPORT
Date: YYYY-MM-DD
Validator: [Your Name]
Environment: [Dev/Staging/Production]

INFRASTRUCTURE (Pass/Fail):
- Terraform validation: [Pass/Fail]
- VM deployment: [Pass/Fail]
- Resource creation: [Pass/Fail]
- SSH access: [Pass/Fail]
- Health check: [Pass/Fail]
- Resource cleanup: [Pass/Fail]

IDP/BACKSTAGE (Pass/Fail):
- Installation: [Pass/Fail]
- Server startup: [Pass/Fail]
- UI access: [Pass/Fail]
- Software catalog: [Pass/Fail]
- Templates: [Pass/Fail]

GITOPS (Pass/Fail):
- Configuration: [Pass/Fail]
- Manifests: [Pass/Fail]
- (Optional) Deployment: [Pass/Fail]

OVERALL STATUS: [Pass/Fail]

ISSUES FOUND:
1. [Issue description]
2. [Issue description]

RECOMMENDATIONS:
1. [Recommendation]
2. [Recommendation]
```

---

## 🆘 Troubleshooting

### **Issue: Terraform validation fails**

**Fix:**
```bash
cd terraform/environments/dev
~/bin/terraform init
~/bin/terraform validate
# Check error message
```

### **Issue: Backstage won't start**

**Fix:**
```bash
cd backstage-app
rm -rf node_modules .cache
yarn install
yarn dev
```

### **Issue: VM deployment fails**

**Fix:**
```bash
# Check Azure credentials
az login --service-principal \
  -u $ARM_CLIENT_ID \
  -p $ARM_CLIENT_SECRET \
  --tenant $ARM_TENANT_ID

# Check quota
az vm list-usage --location eastus --output table
```

### **Issue: Can't SSH to VM**

**Fix:**
```bash
# Check NSG rules
az network nsg rule list \
  --resource-group openclaw-dev-rg \
  --nsg-name openclaw-dev-nsg

# Check VM is running
az vm show -d \
  --resource-group openclaw-dev-rg \
  --name openclaw-dev-vm \
  --query powerState
```

---

## ✅ Success Criteria

**Infrastructure:** All resources deploy, accessible, and cleanly destroy  
**IDP/Backstage:** UI loads, catalog works, templates functional  
**GitOps:** Configurations valid, (optional) ArgoCD deploys  

**If all criteria met:** ✅ **VALIDATION COMPLETE - PRODUCTION READY**

---

## 📞 Support

**Issues?**
- Check logs: `journalctl -u openclaw`
- GitHub Issues: https://github.com/appOrb/openClaw/issues
- Discord: #general
- Documentation: All READMEs in project

---

**Good luck with validation!** 🚀
