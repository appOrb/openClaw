# OpenClaw Backup Module Variables

variable "environment" {
  description = "Environment name"
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

variable "vm_ids" {
  description = "List of VM IDs to backup"
  type        = list(string)
  default     = []
}

variable "daily_retention_days" {
  description = "Number of days to retain daily backups"
  type        = number
  default     = 7
}

variable "weekly_retention_weeks" {
  description = "Number of weeks to retain weekly backups"
  type        = number
  default     = 4
}

variable "monthly_retention_months" {
  description = "Number of months to retain monthly backups"
  type        = number
  default     = 12
}

variable "yearly_retention_years" {
  description = "Number of years to retain yearly backups"
  type        = number
  default     = 1
}

variable "snapshot_replication_type" {
  description = "Snapshot storage replication type"
  type        = string
  default     = "LRS"
  
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS"], var.snapshot_replication_type)
    error_message = "Replication type must be LRS, GRS, RAGRS, or ZRS."
  }
}

variable "snapshot_retention_days" {
  description = "Snapshot retention days"
  type        = number
  default     = 30
}

variable "admin_email" {
  description = "Admin email for backup alerts"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
