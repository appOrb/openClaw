# OpenClaw Terraform Infrastructure

Production-grade infrastructure-as-code for deploying OpenClaw on multiple Azure platforms.

---

## 🏗️ Architecture

### **Platforms Supported:**
1. **Azure VM** - Single instance, lowest cost
2. **Azure Container Instances (ACI)** - Serverless containers
3. **Azure Kubernetes Service (AKS)** - Full orchestration

### **Environments:**
- **dev** - Development/testing (B1s VM, auto-shutdown)
- **staging** - Pre-production (B2s VM)
- **production** - Production (AKS cluster)

---

## 📁 Directory Structure

```
terraform/
├── environments/           # Environment-specific configs
│   ├── dev/               # Development environment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   ├── staging/           # Staging environment
│   └── production/        # Production environment
│
├── modules/               # Reusable Terraform modules
│   ├── openclaw-vm/      # OpenClaw on Azure VM
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── scripts/
│   │       └── bootstrap.sh
│   ├── openclaw-aci/     # OpenClaw on ACI
│   ├── openclaw-aks/     # OpenClaw on AKS
│   ├── backup/           # Backup & restore
│   └── monitoring/       # Health monitoring
│
├── shared/               # Shared configuration
│   ├── backend.tf        # Remote state config
│   ├── providers.tf      # Provider versions
│   └── variables.tf      # Common variables
│
└── docs/                 # Documentation
    ├── deployment-vm.md
    ├── deployment-aci.md
    └── deployment-aks.md
```

---

## 🚀 Quick Start

### **Prerequisites**

1. **Azure CLI** installed and authenticated
2. **Terraform** >= 1.5.0 installed
3. **Service Principal** with Contributor access
4. **Remote State** storage account configured

### **Authentication**

Set environment variables for Azure authentication:

```bash
export ARM_CLIENT_ID="f2410d10-07d1-49e2-af61-dba86cc9b441"
export ARM_CLIENT_SECRET="your-secret-here"
export ARM_TENANT_ID="1b9184b9-e785-4727-a33d-f9526fe07006"
export ARM_SUBSCRIPTION_ID="05a43f56-f126-4bf1-bb97-9ca4d91dfcb5"
```

### **Deploy Development Environment**

```bash
# Navigate to dev environment
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Review plan
terraform plan

# Apply (deploy)
terraform apply

# Get outputs
terraform output
```

---

## 💰 Cost Breakdown

### **Development (dev)**
| Resource | SKU | Cost/Month | Cost/Day |
|----------|-----|------------|----------|
| VM | Standard_B1s | $8.32 | $0.27 |
| Public IP | Standard | $3.65 | $0.12 |
| Storage | 30 GB LRS | $1.53 | $0.05 |
| **Total** | | **~$13.50** | **~$0.44** |

**Auto-shutdown:** Enabled (11 PM UTC) - saves ~$3/mo

### **Staging**
| Resource | SKU | Cost/Month | Cost/Day |
|----------|-----|------------|----------|
| VM | Standard_B2s | $30.37 | $0.99 |
| Public IP | Standard | $3.65 | $0.12 |
| Storage | 30 GB LRS | $1.53 | $0.05 |
| **Total** | | **~$35.55** | **~$1.16** |

### **Production (AKS)**
| Resource | SKU | Cost/Month | Cost/Day |
|----------|-----|------------|----------|
| AKS Nodes (3x) | Standard_B2s | $91.11 | $2.97 |
| Load Balancer | Standard | $18.25 | $0.59 |
| Public IP | Standard | $3.65 | $0.12 |
| Storage | 100 GB Premium | $19.20 | $0.63 |
| **Total** | | **~$132.21** | **~$4.31** |

---

## 🔧 Configuration

### **Remote State Backend**

Already configured in `terraform/shared/backend.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "openclaw-tfstate-rg"
    storage_account_name = "oclawtfstate67d82d59"
    container_name       = "tfstate"
    key                  = "openclaw-{environment}.tfstate"
  }
}
```

### **Variables**

**Required Variables:**
- `subscription_id` - Azure Subscription ID
- `tenant_id` - Azure Tenant ID
- `client_id` - Service Principal Client ID
- `client_secret` - Service Principal Secret
- `ssh_public_key` - SSH public key for VM access
- `github_token` - GitHub PAT
- `copilot_token` - GitHub Copilot token

**Optional Variables:**
- `location` - Azure region (default: "eastus")
- `vm_size` - VM SKU (default: "Standard_B2s")
- `agents_count` - Number of agents (default: 9)
- `enable_auto_shutdown` - Auto-shutdown (default: false)

### **terraform.tfvars Example**

```hcl
# Azure Authentication
subscription_id = "05a43f56-f126-4bf1-bb97-9ca4d91dfcb5"
tenant_id       = "1b9184b9-e785-4727-a33d-f9526fe07006"
client_id       = "f2410d10-07d1-49e2-af61-dba86cc9b441"
# client_secret set via TF_VAR_client_secret

# Configuration
location       = "eastus"
admin_username = "azureuser"

# Tags
tags = {
  Project     = "OpenClaw"
  Environment = "Development"
  ManagedBy   = "Terraform"
}
```

---

## 📋 Deployment Workflows

### **Development Workflow**

```bash
# 1. Navigate to environment
cd terraform/environments/dev

# 2. Initialize (first time)
terraform init

# 3. Validate configuration
terraform validate

# 4. Plan changes
terraform plan -out=tfplan

# 5. Apply changes
terraform apply tfplan

# 6. Get outputs
terraform output openclaw_url
```

### **Destroy Resources**

```bash
# Destroy all resources
terraform destroy

# Or target specific resources
terraform destroy -target=module.openclaw_vm
```

---

## 🔒 Security

### **Secrets Management**

**Never commit secrets to Git!**

Use environment variables for sensitive data:

```bash
export TF_VAR_client_secret="your-secret"
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"
export TF_VAR_github_token="ghp_..."
export TF_VAR_copilot_token="cpt_..."
```

### **State File Security**

Remote state is stored in Azure Storage with:
- ✅ Encryption at rest
- ✅ Access control via RBAC
- ✅ State locking (prevents concurrent changes)
- ✅ Versioning enabled

### **Network Security**

- ✅ Network Security Groups (NSG)
- ✅ SSH key authentication (no passwords)
- ✅ HTTPS only (via Nginx + Let's Encrypt)
- ✅ Auto-shutdown for dev environment

---

## 📊 Outputs

After deployment, Terraform provides:

```hcl
openclaw_url         = "https://openclaw-dev-abc123.eastus.cloudapp.azure.com"
public_ip_address    = "20.25.48.140"
ssh_command          = "ssh azureuser@20.25.48.140"
resource_group_name  = "openclaw-dev-rg"
vm_name              = "dev-openclaw-vm"
```

---

## 🧪 Testing

### **Verify Deployment**

```bash
# Check VM is running
az vm list --resource-group openclaw-dev-rg --output table

# SSH to VM
ssh azureuser@$(terraform output -raw public_ip_address)

# Check OpenClaw service
sudo systemctl status openclaw

# Check logs
sudo journalctl -u openclaw -f

# Test health endpoint
curl http://localhost/health
```

### **Validation Steps**

1. ✅ VM is running
2. ✅ OpenClaw service is active
3. ✅ Keycloak is running (Docker)
4. ✅ Nginx is configured
5. ✅ Health endpoint responds
6. ✅ All 9 agents are active

---

## 🐛 Troubleshooting

### **Common Issues**

**Issue: Authentication failed**
```bash
# Verify service principal
az login --service-principal \
  -u $ARM_CLIENT_ID \
  -p $ARM_CLIENT_SECRET \
  --tenant $ARM_TENANT_ID

# Check permissions
az role assignment list --assignee $ARM_CLIENT_ID
```

**Issue: Remote state access denied**
```bash
# Verify storage account access
az storage account show \
  --name oclawtfstate67d82d59 \
  --resource-group openclaw-tfstate-rg
```

**Issue: VM deployment fails**
```bash
# Check quota
az vm list-usage --location eastus --output table

# Check SKU availability
az vm list-skus --location eastus --size Standard_B1s
```

---

## 📚 Documentation

- [VM Deployment Guide](docs/deployment-vm.md)
- [ACI Deployment Guide](docs/deployment-aci.md)
- [AKS Deployment Guide](docs/deployment-aks.md)
- [Backup & Restore](docs/backup-restore.md)
- [Monitoring Setup](docs/monitoring.md)
- [Cost Optimization](docs/cost-optimization.md)

---

## 🔄 CI/CD Integration

GitHub Actions workflows (coming soon):
- `.github/workflows/deploy-vm.yml`
- `.github/workflows/deploy-aci.yml`
- `.github/workflows/deploy-aks.yml`
- `.github/workflows/health-check.yml`

---

## 📝 Changelog

### [2026-04-24] - Initial Release
- Production-grade Terraform structure
- Azure VM module (complete)
- Remote state backend configured
- Development environment ready
- Auto-shutdown for cost savings
- Bootstrap script for OpenClaw installation

### [Coming Soon]
- ACI module
- AKS module
- Backup module
- Monitoring module
- GitHub Actions workflows
- Backstage integration

---

## 👥 Contributors

- **OpenClaw AppOrb** - Infrastructure & DevOps
- **reevelobo** - Project Owner

---

## 📄 License

MIT License - See LICENSE file for details

---

**Repository:** https://github.com/appOrb/openClaw  
**Branch:** `feature/production-infrastructure`  
**Status:** 🟡 In Development (VM module complete, ACI/AKS pending)
