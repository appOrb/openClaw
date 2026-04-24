# OpenClaw Production Infrastructure

**Multi-platform deployment infrastructure for OpenClaw with Backstage IDP, ArgoCD GitOps, and enterprise-grade operational procedures.**

[![Infrastructure](https://img.shields.io/badge/infrastructure-terraform-623CE4?logo=terraform)](https://www.terraform.io/)
[![Platform](https://img.shields.io/badge/platform-azure-0078D4?logo=microsoft-azure)](https://azure.microsoft.com/)
[![IDP](https://img.shields.io/badge/IDP-backstage-9BF0E1?logo=backstage)](https://backstage.io/)
[![GitOps](https://img.shields.io/badge/GitOps-argocd-EE7B30?logo=argo)](https://argoproj.github.io/)

---

## 🚀 Quick Start

```bash
# Deploy development VM
./deploy.sh dev vm apply

# Check status
./army-status.sh

# Destroy when done
./deploy.sh dev vm destroy
```

---

## 📦 What's Included

### **Infrastructure-as-Code (Terraform)**
- ✅ **5 Modules:** VM, ACI, AKS, Backup, Monitoring
- ✅ **3 Environments:** dev, staging, production
- ✅ **Remote State:** Azure Storage backend
- ✅ **Multi-Platform:** Virtual Machines, Container Instances, Kubernetes

### **Deployment Automation**
- ✅ **deploy.sh** — Master deployment script
- ✅ **deploy-army.sh** — Multi-VM deployment
- ✅ **validate.sh** — Pre-deployment validation
- ✅ **army-status.sh** — Health monitoring

### **Developer Platform (Backstage IDP)**
- ✅ Software Catalog
- ✅ Deployment Templates
- ✅ GitHub Integration
- ✅ Azure Integration
- ✅ TechDocs
- ✅ Cost Insights

### **GitOps (ArgoCD)**
- ✅ Continuous Deployment
- ✅ Multi-Environment Sync
- ✅ Rollback Support
- ✅ Health Monitoring

### **Enterprise Documentation**
- ✅ **Test Procedures** (10 tests, 15 KB)
- ✅ **Deployment SOPs** (10 procedures, 21 KB)
- ✅ **Validation Guides** (15 KB)
- ✅ **Troubleshooting**

---

## 🏗️ Architecture

### **Platform Options**

| Platform | Use Case | Cost/Month | Setup Time |
|----------|----------|------------|------------|
| **VM** | Development, testing | $13.50 | 15 min |
| **ACI** | Staging, UAT | $12.00 | 10 min |
| **AKS** | Production | $132.00 | 30 min |
| **Army** | Distributed workloads | $27/VM | 20 min |

### **Network Architecture**

```
┌─────────────────────────────────────────────────────┐
│                  Azure Subscription                  │
├─────────────────────────────────────────────────────┤
│                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │   Dev (VM)   │  │Staging (ACI) │  │Prod (AKS) │ │
│  │              │  │              │  │           │ │
│  │ B1s Instance │  │ 1 vCPU       │  │ 3 Nodes   │ │
│  │ $13.50/mo    │  │ 1.5 GB RAM   │  │ $132/mo   │ │
│  └──────────────┘  └──────────────┘  └───────────┘ │
│                                                       │
│  ┌─────────────────────────────────────────────────┐│
│  │              OpenClaw Army (N VMs)              ││
│  │  Shared VNet, Separate Subnets                  ││
│  │  Load Balanced, Auto-Scaling                    ││
│  └─────────────────────────────────────────────────┘│
│                                                       │
│  ┌─────────────────────────────────────────────────┐│
│  │         Backstage IDP + ArgoCD GitOps           ││
│  │  Developer Portal & Continuous Deployment       ││
│  └─────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────┘
```

---

## 📋 Prerequisites

- **Terraform** v1.14.9+ ([download](https://www.terraform.io/downloads))
- **Azure CLI** ([install](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- **Azure Subscription** (active)
- **Service Principal** (with Contributor role)
- **SSH Key Pair** (~/.ssh/id_rsa)
- **GitHub Token** (optional, for integrations)

---

## 🎯 Deployment Options

### **Option 1: Development VM**

**Cost:** $0.44/day ($13.50/month)  
**Setup Time:** 15 minutes  
**Use Case:** Development, testing, demos

```bash
# Set credentials
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-secret"
export ARM_TENANT_ID="your-tenant-id"
export ARM_SUBSCRIPTION_ID="your-subscription-id"

# Validate
./validate.sh

# Deploy
./deploy.sh dev vm apply

# Get IP
cd terraform/environments/dev
terraform output public_ip_address

# SSH
ssh azureuser@<IP>

# Destroy
./deploy.sh dev vm destroy
```

**Follow:** [SOP-001: Development VM Deployment](DEPLOYMENT_SOPS.md#sop-001-development-vm-deployment)

---

### **Option 2: Staging Container (ACI)**

**Cost:** $0.40/day ($12/month)  
**Setup Time:** 10 minutes  
**Use Case:** Staging, UAT, pre-production

```bash
# Deploy
./deploy.sh staging aci apply

# Get FQDN
cd terraform/environments/staging
terraform output fqdn

# Test
curl http://<FQDN>/health

# Destroy
./deploy.sh staging aci destroy
```

**Follow:** [SOP-002: Staging ACI Deployment](DEPLOYMENT_SOPS.md#sop-002-staging-aci-deployment)

---

### **Option 3: Production Kubernetes (AKS)**

**Cost:** $4.31/day ($132/month)  
**Setup Time:** 45 minutes  
**Use Case:** Production workloads, high availability

```bash
# Prerequisites
# - Change request approved
# - UAT completed
# - Maintenance window scheduled
# - Backup completed

# Deploy
./deploy.sh production aks apply

# Get credentials
az aks get-credentials \
  --resource-group openclaw-production-rg \
  --name openclaw-production-aks

# Verify
kubectl get nodes
kubectl get pods -n openclaw-production

# Deploy applications (ArgoCD)
kubectl apply -f gitops/argocd/argocd-install.yaml
kubectl apply -f gitops/apps/openclaw.yaml

# Monitor
argocd app get openclaw-production

# Rollback (if needed)
argocd app rollback openclaw-production
```

**Follow:** [SOP-003: Production AKS Deployment](DEPLOYMENT_SOPS.md#sop-003-production-aks-deployment)

---

### **Option 4: Multi-VM Army**

**Cost:** $0.88/day per VM  
**Setup Time:** 20 minutes  
**Use Case:** Distributed workloads, multiple agents

```bash
# Deploy N VMs (e.g., 5)
./deploy-army.sh 5

# Check status
./army-status.sh

# SSH to VMs
cd army-deployment
terraform output ssh_commands

# Test connectivity
for IP in $(terraform output -json vm_ips | python3 -c "import sys,json; print(' '.join(json.load(sys.stdin).values()))"); do
  echo "Testing $IP..."
  ssh azureuser@$IP "hostname && openclaw status"
done

# Destroy
./destroy-army.sh
```

**Follow:** [SOP-004: Multi-VM Army Deployment](DEPLOYMENT_SOPS.md#sop-004-multi-vm-army-deployment)

---

## 🏢 Backstage Developer Portal

### **Installation**

```bash
cd backstage-app
./setup.sh

# Configure
cp .env.example .env
nano .env  # Add GITHUB_TOKEN

# Start
yarn dev

# Access
open http://localhost:3000
```

### **Features**
- **Software Catalog** — View all OpenClaw deployments
- **Templates** — Deploy new instances with forms
- **TechDocs** — Integrated documentation
- **Cost Insights** — Track Azure spending
- **GitHub Integration** — View repos, PRs, workflows

**Follow:** [SOP-005: Backstage IDP Setup](DEPLOYMENT_SOPS.md#sop-005-backstage-idp-setup)

---

## 📊 Testing

### **Pre-Deployment Validation**

```bash
# Run all validation tests
./validate.sh

# Expected: 50+ tests passing
```

### **Infrastructure Testing**

```bash
# Test VM deployment
# Follow: TEST-INF-001

# Test Army deployment
# Follow: TEST-INF-002

# Test ACI deployment
# Follow: TEST-INF-003
```

### **Integration Testing**

```bash
# End-to-end test
# Follow: TEST-INT-001
```

**See:** [TEST_PROCEDURES.md](TEST_PROCEDURES.md) for complete test suite

---

## 🔄 Operations

### **Monitoring**

```bash
# VM health
ssh azureuser@<IP> "systemctl status openclaw"

# Army health
./army-status.sh

# AKS health
kubectl get pods -n openclaw-production
```

### **Scaling**

```bash
# Horizontal Pod Autoscaling (AKS)
kubectl autoscale deployment openclaw \
  -n openclaw-production \
  --cpu-percent=70 \
  --min=3 \
  --max=10

# VM resizing
az vm resize \
  --resource-group openclaw-dev-rg \
  --name openclaw-dev-vm \
  --size Standard_B4ms

# Army scaling
./deploy-army.sh 10  # Scale to 10 VMs
```

**Follow:** [SOP-007: Scaling Operations](DEPLOYMENT_SOPS.md#sop-007-scaling-operations)

### **Backups**

```bash
# Manual backup
az backup protection backup-now \
  --resource-group openclaw-dev-rg \
  --vault-name openclaw-backup-vault \
  --container-name openclaw-dev-vm \
  --item-name openclaw-dev-vm
```

**Follow:** [SOP-008: Backup Procedures](DEPLOYMENT_SOPS.md#sop-008-backup-procedures)

### **Emergency Rollback**

```bash
# Rollback to previous version (5-10 minutes)
argocd app rollback openclaw-production <REVISION>
```

**Follow:** [SOP-006: Emergency Rollback](DEPLOYMENT_SOPS.md#sop-006-emergency-rollback)

---

## 📚 Documentation

### **For Operators**
- [DEPLOYMENT_SOPS.md](DEPLOYMENT_SOPS.md) — 10 standard operating procedures
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) — Complete deployment guide
- [VALIDATION_GUIDE.md](VALIDATION_GUIDE.md) — Step-by-step validation
- [QUICK_VALIDATION.md](QUICK_VALIDATION.md) — Rapid checklist

### **For Testers**
- [TEST_PROCEDURES.md](TEST_PROCEDURES.md) — 10 comprehensive test procedures

### **For Developers**
- [backstage-app/README.md](backstage-app/README.md) — Backstage setup
- [terraform/README.md](terraform/README.md) — Terraform modules

### **For Army Deployments**
- [ARMY_CONFIG.md](ARMY_CONFIG.md) — Multi-VM configuration

---

## 🔧 Troubleshooting

### **Validation Fails**

```bash
# Check Terraform version
terraform version  # Expected: v1.14.9+

# Check Azure login
az account show

# Check SSH key
ls -la ~/.ssh/id_rsa.pub
```

### **Deployment Fails**

```bash
# Check logs
cd terraform/environments/dev
terraform show

# Re-run with debug
TF_LOG=DEBUG terraform apply
```

### **Service Not Starting**

```bash
# Check service status
ssh azureuser@<IP> "systemctl status openclaw"

# Check logs
ssh azureuser@<IP> "journalctl -u openclaw -f"
```

### **Need Help?**

1. Check [VALIDATION_GUIDE.md](VALIDATION_GUIDE.md)
2. Review [DEPLOYMENT_SOPS.md](DEPLOYMENT_SOPS.md)
3. See [TEST_PROCEDURES.md](TEST_PROCEDURES.md)
4. Open GitHub Issue

---

## 💰 Cost Breakdown

### **Development**
- VM (B1s): $13.50/month
- Storage: $2.00/month
- Network: $1.00/month
- **Total:** $16.50/month

### **Staging**
- ACI (1 vCPU, 1.5 GB): $12.00/month
- **Total:** $12.00/month

### **Production**
- AKS (3 nodes): $132.00/month
- Load Balancer: $10.00/month
- Monitoring: $10.00/month
- Backup: $5.00/month
- **Total:** $157.00/month

### **Army (per VM)**
- VM (B2s): $27.00/month
- **5 VMs:** $135.00/month
- **10 VMs:** $270.00/month

### **Total (All Environments)**
- Dev + Staging + Production: $185.50/month
- With 5-VM Army: $320.50/month

---

## 🎉 Features

### **Infrastructure**
- ✅ Multi-platform support (VM, ACI, AKS)
- ✅ Multi-environment (dev, staging, production)
- ✅ Remote state management
- ✅ Automated backups
- ✅ Monitoring & alerting
- ✅ Cost optimization
- ✅ Security hardening

### **Platform**
- ✅ Backstage Developer Portal
- ✅ ArgoCD GitOps
- ✅ Software Catalog
- ✅ Deployment Templates
- ✅ TechDocs
- ✅ Cost Insights

### **Operations**
- ✅ 10 Standard Operating Procedures
- ✅ 10 Test Procedures
- ✅ Validation Scripts
- ✅ Health Monitoring
- ✅ Emergency Rollback
- ✅ Change Management

### **Deployment**
- ✅ One-command deployment
- ✅ Automated validation
- ✅ Progress monitoring
- ✅ Cost estimates
- ✅ Safety confirmations

---

## 🚀 Quick Reference

### **Common Commands**

```bash
# Validate everything
./validate.sh

# Deploy dev VM
./deploy.sh dev vm apply

# Deploy 5-VM army
./deploy-army.sh 5

# Check army status
./army-status.sh

# Destroy dev VM
./deploy.sh dev vm destroy

# Destroy army
./destroy-army.sh

# Start Backstage
cd backstage-app && yarn dev
```

### **Terraform Commands**

```bash
# Initialize
cd terraform/environments/dev
terraform init

# Plan
terraform plan

# Apply
terraform apply

# Show
terraform show

# Outputs
terraform output

# Destroy
terraform destroy
```

### **kubectl Commands**

```bash
# Get nodes
kubectl get nodes

# Get pods
kubectl get pods -n openclaw-production

# Logs
kubectl logs -n openclaw-production -l app=openclaw

# Scale
kubectl scale deployment openclaw -n openclaw-production --replicas=5
```

### **ArgoCD Commands**

```bash
# Get apps
argocd app list

# Sync
argocd app sync openclaw-production

# Rollback
argocd app rollback openclaw-production

# History
argocd app history openclaw-production
```

---

## 📞 Support

### **Documentation**
- Complete guides in this repository
- Step-by-step procedures
- Troubleshooting sections

### **Issues**
- GitHub Issues for bugs
- Discussions for questions
- PRs welcome

---

## 📜 License

MIT License - see [LICENSE](LICENSE) file

---

## 🙏 Acknowledgments

Built with:
- [Terraform](https://www.terraform.io/) — Infrastructure as Code
- [Azure](https://azure.microsoft.com/) — Cloud Platform
- [Backstage](https://backstage.io/) — Developer Portal
- [ArgoCD](https://argoproj.github.io/) — GitOps
- [OpenClaw](https://openclaw.ai/) — AI Agent Platform

---

**Production-ready infrastructure for OpenClaw deployments.** 🚀
