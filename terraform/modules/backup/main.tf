# OpenClaw Backup Module
# Automated backup and point-in-time restore

# Recovery Services Vault
resource "azurerm_recovery_services_vault" "openclaw" {
  name                = "${var.environment}-openclaw-vault"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  
  soft_delete_enabled = true
  
  tags = var.tags
}

# Backup Policy (VMs)
resource "azurerm_backup_policy_vm" "openclaw" {
  name                = "${var.environment}-openclaw-vm-backup-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.openclaw.name
  
  timezone = "UTC"
  
  backup {
    frequency = "Daily"
    time      = "02:00"
  }
  
  retention_daily {
    count = var.daily_retention_days
  }
  
  retention_weekly {
    count    = var.weekly_retention_weeks
    weekdays = ["Sunday"]
  }
  
  retention_monthly {
    count    = var.monthly_retention_months
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }
  
  retention_yearly {
    count    = var.yearly_retention_years
    weekdays = ["Sunday"]
    weeks    = ["First"]
    months   = ["January"]
  }
}

# VM Backup Protection
resource "azurerm_backup_protected_vm" "openclaw" {
  count               = length(var.vm_ids)
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.openclaw.name
  source_vm_id        = var.vm_ids[count.index]
  backup_policy_id    = azurerm_backup_policy_vm.openclaw.id
}

# Storage Account for disk snapshots
resource "azurerm_storage_account" "snapshots" {
  name                     = "${var.environment}oclawsnap${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.snapshot_replication_type
  
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = var.snapshot_retention_days
    }
  }
  
  tags = var.tags
}

# Storage Container for state backups
resource "azurerm_storage_container" "state_backups" {
  name                  = "state-backups"
  storage_account_name  = azurerm_storage_account.snapshots.name
  container_access_type = "private"
}

# Automation Account for scheduled backups
resource "azurerm_automation_account" "openclaw" {
  name                = "${var.environment}-openclaw-automation"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"
  
  tags = var.tags
}

# Runbook for state backup
resource "azurerm_automation_runbook" "state_backup" {
  name                    = "openclaw-state-backup"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.openclaw.name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell"
  
  content = file("${path.module}/scripts/backup-state.ps1")
  
  tags = var.tags
}

# Schedule for state backup
resource "azurerm_automation_schedule" "state_backup" {
  name                    = "openclaw-state-backup-schedule"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.openclaw.name
  frequency               = "Day"
  interval                = 1
  timezone                = "UTC"
  start_time              = "2026-04-25T02:00:00Z"
  
  description = "Daily OpenClaw state backup"
}

# Link runbook to schedule
resource "azurerm_automation_job_schedule" "state_backup" {
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.openclaw.name
  schedule_name           = azurerm_automation_schedule.state_backup.name
  runbook_name            = azurerm_automation_runbook.state_backup.name
}

# Random suffix
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Monitor Action Group (alerts)
resource "azurerm_monitor_action_group" "backup_alerts" {
  name                = "${var.environment}-openclaw-backup-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "bkpalert"
  
  email_receiver {
    name                    = "admin"
    email_address           = var.admin_email
    use_common_alert_schema = true
  }
  
  tags = var.tags
}

# Alert rule for backup failures
resource "azurerm_monitor_metric_alert" "backup_failure" {
  name                = "${var.environment}-openclaw-backup-failure-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_recovery_services_vault.openclaw.id]
  
  criteria {
    metric_namespace = "Microsoft.RecoveryServices/vaults"
    metric_name      = "BackupHealthEvent"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 0
    
    dimension {
      name     = "HealthStatus"
      operator = "Include"
      values   = ["Critical"]
    }
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.backup_alerts.id
  }
  
  severity    = 1
  description = "Alert when backup fails"
  
  tags = var.tags
}
