# OpenClaw ACI Module Outputs

output "container_group_id" {
  description = "Container Group ID"
  value       = azurerm_container_group.openclaw.id
}

output "container_group_name" {
  description = "Container Group name"
  value       = azurerm_container_group.openclaw.name
}

output "fqdn" {
  description = "Fully qualified domain name"
  value       = azurerm_container_group.openclaw.fqdn
}

output "ip_address" {
  description = "Public IP address"
  value       = azurerm_container_group.openclaw.ip_address
}

output "openclaw_url" {
  description = "OpenClaw web interface URL"
  value       = "http://${azurerm_container_group.openclaw.fqdn}"
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.openclaw.name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.openclaw.id
}
