# OpenClaw Monitoring Module
# Comprehensive health monitoring and alerting

# Application Insights
resource "azurerm_application_insights" "openclaw" {
  name                = "${var.environment}-openclaw-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.openclaw.id
  
  retention_in_days = var.retention_days
  
  tags = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "openclaw" {
  name                = "${var.environment}-openclaw-monitoring"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  
  tags = var.tags
}

# Action Group for alerts
resource "azurerm_monitor_action_group" "openclaw" {
  name                = "${var.environment}-openclaw-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "oclalert"
  
  email_receiver {
    name                    = "admin"
    email_address           = var.admin_email
    use_common_alert_schema = true
  }
  
  webhook_receiver {
    name                    = "discord"
    service_uri             = var.discord_webhook_url
    use_common_alert_schema = true
  }
  
  tags = var.tags
}

# Metric Alert: High CPU
resource "azurerm_monitor_metric_alert" "high_cpu" {
  count               = length(var.vm_ids)
  name                = "${var.environment}-openclaw-high-cpu-${count.index}"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_ids[count.index]]
  
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
  
  window_size = "PT5M"
  frequency   = "PT1M"
  severity    = 2
  
  action {
    action_group_id = azurerm_monitor_action_group.openclaw.id
  }
  
  description = "Alert when CPU > 80%"
  
  tags = var.tags
}

# Metric Alert: High Memory
resource "azurerm_monitor_metric_alert" "high_memory" {
  count               = length(var.vm_ids)
  name                = "${var.environment}-openclaw-high-memory-${count.index}"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_ids[count.index]]
  
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 524288000  # 500 MB
  }
  
  window_size = "PT5M"
  frequency   = "PT1M"
  severity    = 2
  
  action {
    action_group_id = azurerm_monitor_action_group.openclaw.id
  }
  
  description = "Alert when available memory < 500 MB"
  
  tags = var.tags
}

# Metric Alert: Disk Space
resource "azurerm_monitor_metric_alert" "low_disk" {
  count               = length(var.vm_ids)
  name                = "${var.environment}-openclaw-low-disk-${count.index}"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_ids[count.index]]
  
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Disk Read Bytes"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 26843545600  # 25 GB
  }
  
  window_size = "PT15M"
  frequency   = "PT5M"
  severity    = 2
  
  action {
    action_group_id = azurerm_monitor_action_group.openclaw.id
  }
  
  description = "Alert when disk usage high"
  
  tags = var.tags
}

# Availability Test (HTTP endpoint)
resource "azurerm_application_insights_web_test" "openclaw" {
  count                   = length(var.endpoint_urls)
  name                    = "${var.environment}-openclaw-availability-${count.index}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = azurerm_application_insights.openclaw.id
  kind                    = "ping"
  frequency               = 300  # 5 minutes
  timeout                 = 120  # 2 minutes
  enabled                 = true
  geo_locations           = ["us-va-ash-azr", "us-ca-sjc-azr", "emea-nl-ams-azr"]
  
  configuration = <<XML
<WebTest Name="OpenClaw-Health-Check" Id="${uuid()}" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="120" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Guid="${uuid()}" Version="1.1" Url="${var.endpoint_urls[count.index]}/health" ThinkTime="0" Timeout="120" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML
  
  tags = var.tags
}

# Alert for availability test failures
resource "azurerm_monitor_metric_alert" "availability" {
  count               = length(var.endpoint_urls)
  name                = "${var.environment}-openclaw-availability-alert-${count.index}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights_web_test.openclaw[count.index].id]
  
  application_insights_web_test_location_availability_criteria {
    web_test_id           = azurerm_application_insights_web_test.openclaw[count.index].id
    component_id          = azurerm_application_insights.openclaw.id
    failed_location_count = 2
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.openclaw.id
  }
  
  severity    = 1
  description = "Alert when endpoint is unavailable from 2+ locations"
  
  tags = var.tags
}

# Dashboard
resource "azurerm_portal_dashboard" "openclaw" {
  name                = "${var.environment}-openclaw-dashboard"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  dashboard_properties = templatefile("${path.module}/templates/dashboard.json", {
    application_insights_id = azurerm_application_insights.openclaw.id
    workspace_id            = azurerm_log_analytics_workspace.openclaw.id
  })
  
  tags = var.tags
}
