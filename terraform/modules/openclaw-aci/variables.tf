# OpenClaw ACI Module Variables

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

variable "dns_label" {
  description = "DNS label for container group"
  type        = string
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 1.0
}

variable "memory_gb" {
  description = "Memory in GB"
  type        = number
  default     = 1.5
}

variable "agents_count" {
  description = "Number of OpenClaw agents"
  type        = number
  default     = 9
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

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

variable "postgres_host" {
  description = "PostgreSQL host"
  type        = string
  default     = ""
}

variable "postgres_database" {
  description = "PostgreSQL database name"
  type        = string
  default     = "keycloak"
}

variable "postgres_username" {
  description = "PostgreSQL username"
  type        = string
  default     = "keycloak"
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "keycloak_admin_password" {
  description = "Keycloak admin password"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
