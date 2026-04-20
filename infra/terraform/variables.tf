variable "prefix" {
  type        = string
  description = "Short prefix for all resource names"
  default     = "openclaw"
}

variable "location" {
  type        = string
  description = "Azure region to deploy into"
  default     = "eastus"
}

variable "environment" {
  type        = string
  description = "Deployment environment label (e.g. production, staging)"
  default     = "production"
}

variable "vm_size" {
  type        = string
  description = "Azure VM SKU. Standard_B2s gives 2 vCPU / 4 GB RAM (~$30/mo)"
  default     = "Standard_B2s"
}

variable "admin_username" {
  type        = string
  description = "Admin username created on the VM"
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Local path to your SSH public key (used for VM access)"
  default     = "~/.ssh/id_rsa.pub"
  sensitive   = true
}

variable "ssh_private_key_path" {
  type        = string
  description = "Local path to your SSH private key (used by Terraform remote-exec provisioners)"
  default     = "~/.ssh/id_rsa"
  sensitive   = true
}

variable "github_token" {
  type        = string
  description = "GitHub PAT (repo + workflow scopes) used by OpenClaw to push code and open PRs. Never stored in state — written only to ~/.openclaw/.env on the VM."
  sensitive   = true
}

variable "dns_label" {
  type        = string
  description = "DNS label for the public IP — must be unique in the region. FQDN will be <dns_label>.<region>.cloudapp.azure.com"
  default     = "openclaw"
}

variable "copilot_pat" {
  type        = string
  description = "Classic GitHub PAT with 'copilot' scope — used by OpenClaw to call GitHub Copilot API. Create one at: https://github.com/settings/tokens/new?scopes=copilot. Marked sensitive; written only to ~/.openclaw/auth-profiles.json on the VM."
  sensitive   = true
  default     = ""
}

variable "github_agent_pat" {
  type        = string
  description = "Classic GitHub PAT with 'repo, workflow, read:org' scopes — used by gh CLI on the VM so agents can clone/push to appOrb repos. Create at: https://github.com/settings/tokens/new?scopes=repo,workflow,read:org"
  sensitive   = true
  default     = ""
}

variable "ssh_source_cidr" {
  type        = string
  description = "CIDR range allowed to SSH into the VM. Restrict to your IP for better security (e.g. '1.2.3.4/32')"
  default     = "*"
}
