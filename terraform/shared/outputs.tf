# Shared Module Outputs

output "location" {
  description = "Azure region"
  value       = var.location
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "tags" {
  description = "Common resource tags"
  value       = var.tags
}

output "resource_group_name" {
  description = "Standard resource group name format"
  value       = "${var.project_name}-${var.environment}-rg"
}
