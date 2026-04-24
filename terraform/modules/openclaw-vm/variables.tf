# OpenClaw VM Module Variables

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vm_size" {
  description = "VM size/SKU"
  type        = string
  default     = "Standard_B2s"
  
  validation {
    condition     = can(regex("^Standard_B[0-9]", var.vm_size))
    error_message = "VM size must be a B-series for cost optimization."
  }
}

variable "admin_username" {
  description = "Admin username for VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

variable "domain_label" {
  description = "DNS domain label for public IP"
  type        = string
}

variable "agents_count" {
  description = "Number of OpenClaw agents to deploy"
  type        = number
  default     = 9
  
  validation {
    condition     = var.agents_count > 0 && var.agents_count <= 20
    error_message = "Agents count must be between 1 and 20."
  }
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "copilot_token" {
  description = "GitHub Copilot API Token"
  type        = string
  sensitive   = true
}

variable "enable_auto_shutdown" {
  description = "Enable automatic VM shutdown (dev only)"
  type        = bool
  default     = false
}

variable "auto_shutdown_time" {
  description = "Auto-shutdown time in 24h format (HHMM)"
  type        = string
  default     = "2300"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
