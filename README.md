# OpenClaw — Azure-Hosted AI Developer Platform

> OpenClaw is an employee. Paperclip is the company.

This repo contains the **infrastructure code and configuration** to host:
- **[Paperclip](https://paperclip.ing)** — AI company control plane (org chart, goals, budgets, heartbeats)
- **[OpenClaw](https://openclaw.ai)** — 7 always-on AI agents, each with a specialized role

Both run on a single Azure VM (~$36/mo) with continuous uptime.

🌐 **Live at:** https://openclaw-reevelobo.eastus.cloudapp.azure.com

---

## The Team

| Agent | Role | Specialty |
|---|---|---|
| **Alex** | engineer | Senior Full-Stack Developer |
| **Orion** | cto | Principal Architect |
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
│   ├── vm-setup.sh                 ← bootstrap script (run by Terraform)
│   └── keycloak-setup.sh           ← Keycloak + oauth2-proxy setup (run by Terraform)
├── openclaw/
│   ├── config.json                 ← OpenClaw persona + model routing config
│   └── skills/                     ← 7 developer skill definition files
├── paperclip/
│   └── company.yaml                ← Paperclip company + all 7 agent configs
├── keycloak/
│   ├── realm-export.json           ← Keycloak realm + Paperclip OIDC client config
│   └── docker-compose.yml          ← Docker Compose for Keycloak (internal port 8080)
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
- `keycloak_admin_password` — strong password for Keycloak admin console (≥ 8 chars)
- `keycloak_client_secret` — random UUID for the Paperclip OIDC client (`uuidgen`)
- `oauth2_proxy_cookie_secret` — 32-byte base64 cookie secret (`openssl rand -base64 32 | tr -d '\n'`)

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
5. **Deploys Keycloak + oauth2-proxy** (`keycloak-setup.sh`):
   - Installs Docker Engine
   - Starts Keycloak 24 in Docker (port 8080, internal only) with the `openclaw` realm
   - Installs and configures `oauth2-proxy` as an authentication gateway (port 4180)
6. Deploys `nginx/openclaw.conf` — now routes Paperclip through oauth2-proxy

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

## Login Security (Keycloak + oauth2-proxy)

The Paperclip dashboard is protected by [Keycloak](https://www.keycloak.org/) — an enterprise-grade Identity Provider — via [oauth2-proxy](https://oauth2-proxy.github.io/oauth2-proxy/).

### Architecture

```
Browser
  │  HTTPS (443)
  ▼
Nginx
  │  HTTP (4180) — all traffic, including /oauth2/* OIDC callbacks
  ▼
oauth2-proxy ── unauthenticated? ──► Keycloak login (redirect)
  │  authenticated
  │  HTTP (3100)
  ▼
Paperclip
```

- **Keycloak** runs in Docker on port `8080` (internal only — not exposed externally).
- **oauth2-proxy** runs as a systemd service on port `4180`.
- Keycloak admin console is accessible only via an SSH tunnel to prevent external exposure.

### Accessing the Keycloak Admin Console

```bash
ssh -L 8080:localhost:8080 azureuser@$(terraform output -raw public_ip_address)
# Then open: http://localhost:8080/admin  (admin / your keycloak_admin_password)
```

### Creating Users

In the Keycloak admin console:
1. Select realm **openclaw**
2. Go to **Users → Add user**
3. Set a **Credentials** password

### After Enabling SSL (certbot)

Update `cookie-secure` in `/etc/oauth2-proxy.cfg` on the VM:
```bash
sudo sed -i 's/cookie-secure = false/cookie-secure = true/' /etc/oauth2-proxy.cfg
sudo systemctl restart oauth2-proxy
```

### Required Terraform Variables

| Variable | Description | How to generate |
|---|---|---|
| `keycloak_admin_password` | Keycloak admin password (≥8 chars) | Choose a strong password |
| `keycloak_client_secret` | OIDC client secret for Paperclip | `uuidgen` |
| `oauth2_proxy_cookie_secret` | oauth2-proxy cookie encryption key | `openssl rand -base64 32` |

These are marked `sensitive = true` in Terraform — never written to state or logs.

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
| `TF_VAR_keycloak_admin_password` | Keycloak admin password |
| `TF_VAR_keycloak_client_secret` | Paperclip OIDC client secret |
| `TF_VAR_oauth2_proxy_cookie_secret` | oauth2-proxy cookie encryption key |

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
