---
name: github-actions-update
description: Modify CI/CD workflows in .github/workflows/, add repository secrets, and debug failed GitHub Actions runs
modelHint: research
---

# GitHub Actions Update Skill

## Scope
`.github/workflows/` in appOrb/openClaw. Workflows: `deploy.yml` (Terraform apply on push to main).

## Workflow Structure
```yaml
name: Deploy OpenClaw
on:
  push:
    branches: [main]
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform init
        env:
          TF_VAR_copilot_pat: ${{ secrets.COPILOT_PAT }}
          # ... other secrets
```

## Adding a New Secret
1. Go to repo Settings → Secrets and Variables → Actions → New repository secret
2. Add `TF_VAR_*` prefix for Terraform variables
3. Reference in workflow: `${{ secrets.MY_SECRET }}`

## Required Secrets
| Secret Name | Usage |
|---|---|
| `AZURE_CLIENT_ID` | Service principal app ID |
| `AZURE_CLIENT_SECRET` | Service principal secret |
| `AZURE_TENANT_ID` | Azure tenant |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription |
| `COPILOT_PAT` | GitHub classic PAT with `copilot` scope |
| `KEYCLOAK_ADMIN_PASSWORD` | Keycloak admin |
| `PAPERCLIP_CLIENT_SECRET` | OIDC client secret |

## Debugging Failed Runs
1. Click the failed workflow run in GitHub → expand failed step
2. For Terraform errors: look for `Error:` lines in the `terraform apply` output
3. For SSH provisioner failures: check null_resource output — it includes VM-side stderr
4. For secret issues: confirm secret name matches exactly (case-sensitive)
