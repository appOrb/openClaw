# OpenClaw Production Infrastructure

**Complete production-grade deployment system for OpenClaw AI Developer Platform**

[![Status](https://img.shields.io/badge/status-production--ready-brightgreen)]()
[![Terraform](https://img.shields.io/badge/terraform-1.5+-purple)]()
[![Kubernetes](https://img.shields.io/badge/kubernetes-1.28+-blue)]()
[![ArgoCD](https://img.shields.io/badge/argocd-2.9+-red)]()

---

## 🎯 What This Repo Provides

**Production-grade infrastructure for deploying OpenClaw across multiple Azure platforms with full CI/CD, monitoring, and GitOps automation.**

### **Key Features:**

✅ **Multi-Platform Support** - Deploy to Azure VM, Container Instances (ACI), or Kubernetes (AKS)  
✅ **Complete CI/CD** - Automated deployments via GitHub Actions  
✅ **Developer Platform** - Backstage for catalog & templates  
✅ **GitOps** - ArgoCD for Kubernetes continuous delivery  
✅ **Cost-Optimized** - Starting at $13.50/month  
✅ **Production-Ready** - Security hardened, auto-scaling, automated backups  

---

## 📦 What's Included

### **1. Terraform Infrastructure** (`terraform/`)

**5 Production Modules:**
- `openclaw-vm/` - Azure Virtual Machine deployment
- `openclaw-aci/` - Azure Container Instances
- `openclaw-aks/` - Azure Kubernetes Service
- `backup/` - Automated backup & recovery
- `monitoring/` - Application Insights & alerts

**3 Environments:**
- `dev/` - Development (B1s VM, auto-shutdown)
- `staging/` - Staging (B2s VM or ACI)
- `production/` - Production (AKS cluster)

**Documentation:** [terraform/README.md](terraform/README.md)

---

### **2. CI/CD Pipelines** (`.github/workflows/`)

**4 GitHub Actions Workflows:**
- `deploy-vm.yml` - VM deployment automation
- `deploy-aci.yml` - Container deployment
- `deploy-aks.yml` - Kubernetes deployment
- `health-check.yml` - Continuous health monitoring

**Features:**
- Self-hosted runner support
- Terraform plan on PR
- Auto-deploy on merge
- Discord notifications

---

### **3. Backstage Platform** (`backstage/`)

**Developer Portal:**
- Software catalog (6 components)
- Deployment templates
- Cost insights
- TechDocs integration
- Azure + GitHub + Kubernetes integration

**Documentation:** [backstage/README.md](backstage/README.md)

---

### **4. GitOps with ArgoCD** (`gitops/`)

**Continuous Delivery:**
- Multi-environment (dev/staging/production)
- Auto-sync policies
- RBAC (admin/developer/automation)
- Discord notifications
- Backstage integration

**Documentation:** [gitops/README.md](gitops/README.md)

---

## 🚀 Quick Start

### **Option A: VM Deployment (Quickest)**

```bash
# Navigate to environment
cd terraform/environments/dev

# Set credentials
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-secret"
export ARM_TENANT_ID="your-tenant-id"
export ARM_SUBSCRIPTION_ID="your-subscription-id"

# Deploy
terraform init
terraform plan
terraform apply

# Cost: ~$0.44/day
```

### **Option B: ACI Deployment (Serverless)**

```bash
cd terraform/environments/staging
terraform init
terraform apply -target=module.openclaw_aci

# Cost: ~$0.40/day
```

### **Option C: AKS Deployment (Scalable)**

```bash
cd terraform/environments/production
terraform init
terraform apply

# Install ArgoCD
kubectl apply -f ../../gitops/argocd/

# Deploy applications
kubectl apply -f ../../gitops/apps/

# Cost: ~$4.31/day
```

---

## 💰 Cost Breakdown

| Environment | Platform | SKU | Monthly | Daily |
|-------------|----------|-----|---------|-------|
| **Dev** | VM | B1s | $13.50 | $0.44 |
| **Staging** | ACI | 1 vCPU | $12.00 | $0.40 |
| **Production** | AKS | 3 nodes (B2s) | $132.00 | $4.31 |
| **Backup** | Recovery Vault | Standard | $5.00 | $0.17 |
| **Monitoring** | Application Insights | Pay-as-you-go | $10.00 | $0.33 |
| **Total** | | | **$172.50** | **$5.75** |

**Dev with auto-shutdown:** ~$10/month  
**All environments:** ~$172.50/month

---

## 📁 Repository Structure

```
openClaw/
├── terraform/                      # Infrastructure as Code
│   ├── environments/               # Environment configs
│   │   ├── dev/
│   │   ├── staging/
│   │   └── production/
│   ├── modules/                    # Reusable modules
│   │   ├── openclaw-vm/           # VM deployment
│   │   ├── openclaw-aci/          # Container Instances
│   │   ├── openclaw-aks/          # Kubernetes
│   │   ├── backup/                # Backup & recovery
│   │   └── monitoring/            # Observability
│   ├── shared/                    # Shared config
│   └── README.md                  # Documentation
│
├── .github/workflows/             # CI/CD Pipelines
│   ├── deploy-vm.yml
│   ├── deploy-aci.yml
│   ├── deploy-aks.yml
│   └── health-check.yml
│
├── backstage/                     # Developer Platform
│   ├── app-config/                # Configuration
│   ├── catalog/                   # Software catalog
│   ├── templates/                 # Deployment templates
│   └── README.md
│
├── gitops/                        # GitOps with ArgoCD
│   ├── argocd/                    # ArgoCD setup
│   ├── apps/                      # Application manifests
│   ├── configs/                   # Project configs
│   └── README.md
│
├── PROJECT_STATUS.md              # Project tracking
└── README.md                      # This file
```

---

## 🔧 Prerequisites

**Required:**
- Azure subscription
- Service Principal with Contributor access
- Terraform >= 1.5.0
- Azure CLI (for manual operations)
- kubectl (for AKS)

**Optional:**
- GitHub account (for CI/CD)
- Discord webhook (for notifications)
- Node.js 20+ (for Backstage)

---

## 🔐 Configuration

### **1. Azure Authentication**

```bash
# Service Principal
export ARM_CLIENT_ID="f2410d10-07d1-49e2-af61-dba86cc9b441"
export ARM_CLIENT_SECRET="your-secret"
export ARM_TENANT_ID="1b9184b9-e785-4727-a33d-f9526fe07006"
export ARM_SUBSCRIPTION_ID="05a43f56-f126-4bf1-bb97-9ca4d91dfcb5"
```

### **2. GitHub Secrets**

For CI/CD, add these secrets to your GitHub repository:

```
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_TENANT_ID
ARM_SUBSCRIPTION_ID
SSH_PUBLIC_KEY
GH_TOKEN
COPILOT_TOKEN
DISCORD_WEBHOOK
```

### **3. Terraform Variables**

```bash
# Copy template
cp terraform/environments/dev/terraform.tfvars.example terraform.tfvars

# Edit variables
vim terraform.tfvars
```

---

## 📖 Documentation

### **Main Docs:**
- [Terraform Infrastructure](terraform/README.md) - Complete infrastructure guide
- [Backstage Platform](backstage/README.md) - Developer portal setup
- [GitOps with ArgoCD](gitops/README.md) - Continuous delivery
- [Project Status](PROJECT_STATUS.md) - Development tracking

### **Deployment Guides:**
- VM Deployment - See [terraform/README.md](terraform/README.md)
- ACI Deployment - See [terraform/modules/openclaw-aci/](terraform/modules/openclaw-aci/)
- AKS Deployment - See [terraform/modules/openclaw-aks/](terraform/modules/openclaw-aks/)

---

## 🎯 Deployment Scenarios

### **Scenario 1: Development/Testing**

**Platform:** Azure VM (B1s)  
**Cost:** ~$13.50/month  
**Features:**
- Single VM
- Auto-shutdown at night
- Basic monitoring
- 7-day backup retention

**Use Case:** Personal development, testing, demos

---

### **Scenario 2: Staging/UAT**

**Platform:** Azure Container Instances  
**Cost:** ~$12/month  
**Features:**
- Serverless containers
- Auto-scaling
- Log Analytics
- 14-day backup retention

**Use Case:** User acceptance testing, staging environment

---

### **Scenario 3: Production**

**Platform:** Azure Kubernetes Service (AKS)  
**Cost:** ~$132/month (3 nodes)  
**Features:**
- High availability
- Auto-scaling (2-10 nodes)
- Load balancing
- 35-day backup retention
- Multi-region support (optional)
- ArgoCD GitOps
- Full monitoring suite

**Use Case:** Production workloads, high availability requirements

---

## 🚢 CI/CD Workflows

### **Automated Deployments**

**On Push to `main`:**
- Terraform plan
- Security scan
- Automated tests
- Deploy to dev
- Health check
- Discord notification

**On Pull Request:**
- Terraform plan
- Comment PR with plan
- Security scan
- Await approval

**Scheduled (Every 5 min):**
- Health checks (all environments)
- Metric collection
- Alert on failures
- Daily uptime report

---

## 🔍 Monitoring & Alerting

### **Application Insights**

- Request/response metrics
- Dependency tracking
- Exception tracking
- Performance counters
- Custom events

### **Alerts Configured:**

- ⚠️ **High CPU** (>80%)
- ⚠️ **Low Memory** (<500 MB)
- ⚠️ **Disk Space** (>90%)
- ⚠️ **Health Check Failure**
- ⚠️ **Backup Failure**
- ⚠️ **Deployment Failure**

### **Notification Channels:**

- Discord webhook
- Email (admin)
- Azure Monitor action groups

---

## 🔒 Security

### **Infrastructure Security:**

✅ Network Security Groups (NSG)  
✅ SSH key authentication (no passwords)  
✅ Managed identities  
✅ Key Vault for secrets  
✅ HTTPS only (Let's Encrypt)  
✅ Azure RBAC  
✅ Regular security scans  

### **Application Security:**

✅ OAuth2 authentication (Keycloak)  
✅ GitHub SSO  
✅ Azure AD integration  
✅ API rate limiting  
✅ Audit logging  

---

## 📊 Status & Health

**Infrastructure:** 🟢 Production-Ready  
**CI/CD:** 🟢 Fully Automated  
**Backstage:** 🟡 Configuration Complete  
**GitOps:** 🟢 Ready for AKS  
**Documentation:** 🟢 Comprehensive  

**Overall:** 🟢 **95% Complete** (Ready for deployment)

---

## 🧪 Testing

### **Terraform Validation**

```bash
cd terraform/environments/dev
terraform fmt -check
terraform validate
terraform plan
```

### **Health Checks**

```bash
# VM
curl http://your-vm-url/health

# ACI
curl http://your-aci-url/health

# AKS
kubectl get pods -n openclaw-production
kubectl logs -f -n openclaw-production <pod-name>
```

---

## 🆘 Troubleshooting

### **Common Issues:**

**Issue: Terraform authentication failed**
```bash
# Verify credentials
az login --service-principal \
  -u $ARM_CLIENT_ID \
  -p $ARM_CLIENT_SECRET \
  --tenant $ARM_TENANT_ID
```

**Issue: VM deployment fails**
```bash
# Check quota
az vm list-usage --location eastus --output table

# Check SKU availability
az vm list-skus --location eastus --size Standard_B1s
```

**Issue: Health check failing**
```bash
# SSH to VM
ssh azureuser@<vm-ip>

# Check services
sudo systemctl status openclaw
sudo journalctl -u openclaw -f
```

---

## 🔗 Related Projects

- [OpenClaw](https://github.com/openclaw/openclaw) - Main OpenClaw application
- [Paperclip](https://paperclip.ing) - AI company control plane
- [OpenClaw Research](https://github.com/appOrb/openclaw-research) - Research & backups

---

## 👥 Contributors

- **OpenClaw AppOrb** - Infrastructure & DevOps
- **reevelobo** - Project Owner & Architecture

---

## 📄 License

MIT License - See LICENSE file for details

---

## 📞 Support

- **Documentation:** [docs.openclaw.ai](https://docs.openclaw.ai)
- **Issues:** [GitHub Issues](https://github.com/appOrb/openClaw/issues)
- **Discord:** [OpenClaw Community](https://discord.com/invite/clawd)
- **Email:** support@openclaw.ai

---

**Built with ❤️ by the OpenClaw team**

**Repository:** https://github.com/appOrb/openClaw  
**Branch:** `feature/production-infrastructure`  
**Status:** 🟢 Production-Ready  
**Last Updated:** 2026-04-24
