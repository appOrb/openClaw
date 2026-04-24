# OpenClaw Backup Module Outputs

output "vault_id" {
  description = "Recovery Services Vault ID"
  value       = azurerm_recovery_services_vault.openclaw.id
}

output "vault_name" {
  description = "Recovery Services Vault name"
  value       = azurerm_recovery_services_vault.openclaw.name
}

output "backup_policy_id" {
  description = "Backup policy ID"
  value       = azurerm_backup_policy_vm.openclaw.id
}

output "snapshot_storage_account" {
  description = "Snapshot storage account name"
  value       = azurerm_storage_account.snapshots.name
}

output "automation_account_id" {
  description = "Automation account ID"
  value       = azurerm_automation_account.openclaw.id
}
