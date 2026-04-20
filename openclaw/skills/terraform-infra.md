---
name: terraform-infra
description: Add, modify, or troubleshoot Azure resources in the openClaw Terraform codebase (infra/terraform/)
modelHint: debug
---

# Terraform Infrastructure Skill

## Scope
`infra/terraform/` in appOrb/openClaw. Standard_B2s Ubuntu VM on Azure + networking module + null_resource provisioner chain.

## Key Files
- `main.tf` — null_resource chain: bootstrap → secrets → openclaw_config → openclaw_skills → paperclip_config → keycloak_setup → nginx_config
- `variables.tf` — all inputs; sensitive vars (copilot_pat, github_token, keycloak passwords) marked sensitive
- `modules/networking/` — NSG, VNet, subnet, public IP, NIC, DNS label
- `modules/vm/` — Standard_B2s, Ubuntu 22.04, SSH auth
- `terraform.tfvars.example` — template for local var file

## Workflow

1. **Adding a resource** — edit `main.tf` or the appropriate module; never hardcode values, always parameterize in `variables.tf`
2. **Plan before apply** — always run `terraform plan` and review the diff before applying
3. **Null resource ordering** — if a new provisioner step must run after another, add `depends_on` to the `null_resource`
4. **Secrets** — pass via `TF_VAR_*` environment vars; never write secrets to state or .tfvars files committed to git

## Common Commands
```bash
# From infra/terraform/
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
terraform destroy  # destroys VM but data disk persists if detach_disk = true
```

## Things to Never Do
- Do not store secrets in `terraform.tfvars` committed to git
- Do not change VM size without checking that persistent disk mount survives
- Do not remove `depends_on` chains — provisioners will execute out of order
