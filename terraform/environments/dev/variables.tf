# Azure authentication
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

variable "client_id" {
  description = "Azure client ID (Service Principal)"
  type        = string
}

variable "client_secret" {
  description = "Azure client secret (Service Principal)"
  type        = string
  sensitive   = true
}

# Location and environment
variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
}

# VM configuration
variable "admin_username" {
  description = "Admin username for VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

# OpenClaw configuration
variable "github_token" {
  description = "GitHub token for OpenClaw"
  type        = string
  sensitive   = true
}

variable "copilot_token" {
  description = "GitHub Copilot token for OpenClaw"
  type        = string
  sensitive   = true
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "OpenClaw"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}
