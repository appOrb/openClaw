# OpenClaw — Azure-Hosted AI Developer Platform

> OpenClaw is an employee. Paperclip is the company.

This repo contains the **infrastructure code and configuration** to host:
- **[Paperclip](https://paperclip.ing)** — AI company control plane (org chart, goals, budgets, heartbeats)
- **[OpenClaw](https://openclaw.ai)** — 9 always-on AI agents, each with a specialized role

Both run on a single Azure VM (~$36/mo) with continuous uptime.

🌐 **Live at:** https://openclaw-reevelobo.eastus.cloudapp.azure.com

---

## The Team

| Agent | Role | Specialty |
|---|---|---|
| **Apex** | ceo | Chief Executive Officer |
| **Maven** | cmo | Chief Marketing Officer |
| **Orion** | cto | Principal Architect |
| **Alex** | engineer | Senior Full-Stack Developer |
| **Cipher** | devops | DevSecOps Engineer |
| **Atlas** | devops | Platform Engineer |
| **Forge** | devops | Infrastructure Engineer |
| **Sentinel** | general | Security Specialist |
| **Horizon** | researcher | Forward Engineering Agent |

All agents use **GitHub Copilot** as their LLM backend with task-aware model routing:
- **Haiku 4.5** — repetitive / monotonous tasks (boilerplate, formatting)
- **Sonnet 4.5** — research, creative thinking, architecture decisions
- **GPT-4o** — troubleshooting, logic, debugging

---

## Cost

| Resource | Cost |
|---|---|
| Azure VM Standard_B2s | ~$30/mo |
| OS Disk + Public IP | ~$6/mo |
| GitHub Copilot sub | ~$10/mo (or $0 if existing) |
| **Total** | **~$36–46/mo** |

No per-token LLM billing — all models go through your Copilot subscription.

---

## Repo Structure

```
openClaw/
├── .env.example
├── infra/
│   ├── terraform/                  ← Terraform root module
│   │   ├── versions.tf             ← provider requirements
│   │   ├── main.tf                 ← wires all modules + remote-exec bootstrap
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars.example
│   │   └── modules/
│   │       ├── resource-group/     ← Azure Resource Group
│   │       ├── networking/         ← VNet, NSG, public IP, NIC
│   │       └── vm/                 ← Linux VM (Ubuntu 24.04, B2s)
│   └── vm-setup.sh                 ← bootstrap script (run by Terraform)
├── openclaw/
│   ├── config.json                 ← OpenClaw persona + model routing config
│   └── skills/                     ← 7 developer skill definition files
├── paperclip/
│   └── company.yaml                ← Paperclip company + all 7 agent configs
└── nginx/
    └── openclaw.conf               ← Nginx reverse proxy + SSL config
```

---

## Provision (Fresh Setup)

### Prerequisites
- [Terraform ≥ 1.5](https://developer.hashicorp.com/terraform/install)
- Azure CLI installed and logged in: `az login`
- SSH key pair at `~/.ssh/id_rsa` / `~/.ssh/id_rsa.pub`
- GitHub Copilot subscription active

### Step 1 — Configure

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
- `dns_label` — unique DNS label (e.g. `openclaw-yourname`)
- `github_token` — classic PAT with `repo` + `workflow` scopes
- `copilot_pat` — classic PAT with `copilot` scope ([create here](https://github.com/settings/tokens/new?scopes=copilot))
- `ssh_source_cidr` — restrict to your IP for security

> ⚠️ `copilot_pat` **must be a classic PAT** (`ghp_...`), not a fine-grained token.
> Fine-grained tokens do not support the Copilot API scope.

### Step 2 — Provision + Bootstrap

```bash
terraform init
terraform plan -out=openclaw.tfplan
terraform apply openclaw.tfplan
```

`terraform apply` does everything in order:
1. Creates resource group, VNet, NSG, static IP, NIC, and VM
2. SSHes into the VM and runs `vm-setup.sh`:
   - Installs Node 22, pnpm, Nginx, certbot
   - Installs Paperclip + OpenClaw as systemd daemons
   - Writes `auth-profiles.json` from `copilot_pat` (if set)
   - Configures OpenClaw model routing
   - Runs certbot to get Let's Encrypt SSL
3. Deploys `openclaw/config.json` + all skills
4. Deploys `paperclip/company.yaml`
5. Deploys `nginx/openclaw.conf`

### Step 3 — (If copilot_pat was not set) Authenticate manually

If you didn't set `copilot_pat` in tfvars, authenticate interactively:

```bash
ssh azureuser@$(terraform output -raw public_ip_address)
openclaw models auth login-github-copilot
# Opens a device-flow URL — visit it, enter the code, approve
```

### Step 4 — Validate

Open the Paperclip dashboard at `https://<your-fqdn>`, assign a task to any agent,
and watch the agent execute: e.g. *"Scaffold a FastAPI todo app with PostgreSQL"*.

---

## GitHub Actions CI/CD

The `.github/workflows/deploy.yml` pipeline runs `terraform plan` on every PR and
`terraform apply` on every push to `main`. Required repository secrets:

| Secret | Description |
|---|---|
| `ARM_CLIENT_ID` | Azure service principal client ID |
| `ARM_CLIENT_SECRET` | Azure service principal secret |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID |
| `ARM_TENANT_ID` | Azure tenant ID |
| `OPENCLAW_GITHUB_TOKEN` | Classic PAT (`repo` + `workflow` scopes) |
| `COPILOT_PAT` | Classic PAT with `copilot` scope |
| `SSH_PRIVATE_KEY` | Private key for VM SSH access |
| `SSH_PUBLIC_KEY` | Corresponding public key |

---

## Decommission

```bash
cd infra/terraform
terraform destroy
```

Destroys all Azure resources in the correct dependency order.

---

## Update Agents / Software

```bash
# Update OpenClaw
ssh azureuser@$(terraform output -raw public_ip_address) \
  'npm install -g openclaw@latest && sudo systemctl restart openclaw'

# Update Paperclip
ssh azureuser@$(terraform output -raw public_ip_address) \
  'cd ~/paperclip && git pull && pnpm install && pnpm build && sudo systemctl restart paperclip'
```

## Re-deploy Config Changes

Terraform detects changes to config files via SHA-256 triggers. To push updates:

```bash
# Edit any config file, then:
cd infra/terraform
terraform apply
```
