# OpenClaw — Azure-Hosted AI Developer

> OpenClaw is an employee. Paperclip is the company.

This repo contains the **infrastructure code and configuration** to host:
- **[Paperclip](https://paperclip.ing)** — AI company control plane (org chart, goals, budgets, heartbeats)
- **[OpenClaw](https://openclaw.ai)** — "Alex", your always-on AI developer employee

Both run on a single Azure VM (~$36/mo) with continuous uptime.

---

## What Alex Can Do

| Skill | Description |
|---|---|
| Code generation | Write production code in React, Node.js, Python, Go |
| PR creation | Push a branch and open a GitHub PR |
| Code review | Review a PR diff and leave comments |
| Debug & fix | Analyze stack traces, apply fixes |
| Project scaffold | Generate full-stack project structure |
| Write tests | Generate unit, integration, e2e tests |
| CI/CD setup | Create GitHub Actions or Azure DevOps pipelines |

Alex uses **GitHub Copilot** as its LLM backend with task-aware model routing:
- **Haiku 4.5** — repetitive / monotonous tasks (boilerplate, formatting)
- **Sonnet 4.5** — research, creative thinking, architecture decisions
- **GPT-5.3-Codex** — troubleshooting, logic, debugging

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
│   └── company.yaml                ← Paperclip company + employee config
└── nginx/
    └── openclaw.conf               ← Nginx reverse proxy + SSL config
```

---

## Provision

### Prerequisites
- [Terraform ≥ 1.5](https://developer.hashicorp.com/terraform/install)
- Azure CLI installed and logged in: `az login`
- SSH key pair at `~/.ssh/id_rsa` / `~/.ssh/id_rsa.pub` (or set custom paths)
- GitHub Copilot subscription active

### Step 1 — Configure

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set dns_label (must be unique) and optionally ssh_source_cidr
```

### Step 2 — Provision + Bootstrap (single command)

```bash
terraform init
terraform plan -out=openclaw.tfplan
terraform apply openclaw.tfplan
```

`terraform apply` does everything in order:

1. Creates resource group, VNet, NSG, static IP, NIC, and VM
2. SSHes into the VM and runs `vm-setup.sh` (installs Node 22, pnpm, Nginx, Paperclip + OpenClaw as systemd daemons)
3. Deploys `openclaw/config.json` + all skills to `~/.openclaw/`
4. Deploys `paperclip/company.yaml`
5. Deploys `nginx/openclaw.conf` and reloads Nginx

At the end it prints:

```
public_ip_address   = "x.x.x.x"
fqdn                = "openclaw-yourname.eastus.cloudapp.azure.com"
ssh_command         = "ssh azureuser@x.x.x.x"
copilot_auth_command = "ssh azureuser@x.x.x.x 'openclaw models auth login-github-copilot'"
```

### Step 3 — Authenticate GitHub Copilot (one-time, interactive)

```bash
ssh azureuser@$(terraform output -raw public_ip_address)
openclaw models auth login-github-copilot
# Opens a device-flow URL — visit it, enter the code, approve
```

### Step 4 — SSL (optional, requires a domain)

```bash
ssh azureuser@$(terraform output -raw public_ip_address) \
  'sudo certbot --nginx -d your-domain.com'
```

### Step 5 — Register Alex in Paperclip

Open `http://$(terraform output -raw public_ip_address):3100`, sign in,
and import `paperclip/company.yaml` to register Alex as a Developer employee.

### Step 6 — Validate

Assign a task in Paperclip: *"Scaffold a FastAPI todo app with PostgreSQL"*  
Alex receives the heartbeat, uses GPT-5.3-Codex for logic, writes code, opens a PR.

---

## Decommission

```bash
cd infra/terraform
terraform destroy
```

This destroys **all** Azure resources (VM, NIC, NSG, VNet, public IP, resource group) in
the correct dependency order. No manual cleanup needed.

---

## Re-deploy config changes

Terraform detects changes to `openclaw/config.json`, skills, `paperclip/company.yaml`,
and `nginx/openclaw.conf` via SHA-256 triggers. To push updates:

```bash
# Edit any config file, then:
cd infra/terraform
terraform apply
```

---

## Update OpenClaw / Paperclip software

```bash
# Update OpenClaw
ssh azureuser@$(terraform output -raw public_ip_address) \
  'npm install -g openclaw@latest && sudo systemctl restart openclaw'

# Update Paperclip
ssh azureuser@$(terraform output -raw public_ip_address) \
  'cd ~/paperclip && git pull && pnpm install && pnpm build && sudo systemctl restart paperclip'
```
