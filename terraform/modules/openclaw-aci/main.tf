# OpenClaw ACI (Azure Container Instances) Module
# Deploys OpenClaw as serverless containers

# Container Group
resource "azurerm_container_group" "openclaw" {
  name                = "${var.environment}-openclaw-aci"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  restart_policy      = "Always"
  
  # DNS label for public access
  dns_name_label = var.dns_label
  
  # Main OpenClaw container
  container {
    name   = "openclaw"
    image  = "ghcr.io/openclaw/openclaw:latest"  # TODO: Build this image
    cpu    = var.cpu_cores
    memory = var.memory_gb
    
    # Ports
    ports {
      port     = 80
      protocol = "TCP"
    }
    
    ports {
      port     = 443
      protocol = "TCP"
    }
    
    # Environment variables
    environment_variables = {
      ENVIRONMENT   = var.environment
      AGENTS_COUNT  = var.agents_count
      NODE_ENV      = "production"
    }
    
    # Secure environment variables
    secure_environment_variables = {
      GITHUB_TOKEN       = var.github_token
      COPILOT_TOKEN      = var.copilot_token
      ARM_SUBSCRIPTION_ID = var.subscription_id
      ARM_TENANT_ID      = var.tenant_id
    }
    
    # Volume mounts
    volume {
      name                 = "openclaw-data"
      mount_path          = "/opt/openclaw/data"
      storage_account_name = azurerm_storage_account.openclaw.name
      storage_account_key  = azurerm_storage_account.openclaw.primary_access_key
      share_name          = azurerm_storage_share.openclaw.name
    }
    
    # Liveness probe
    liveness_probe {
      http_get {
        path   = "/health"
        port   = 80
        scheme = "Http"
      }
      initial_delay_seconds = 30
      period_seconds        = 30
      failure_threshold     = 3
      timeout_seconds       = 5
    }
    
    # Readiness probe
    readiness_probe {
      http_get {
        path   = "/health"
        port   = 80
        scheme = "Http"
      }
      initial_delay_seconds = 10
      period_seconds        = 10
      failure_threshold     = 3
      timeout_seconds       = 5
    }
  }
  
  # Keycloak container (authentication)
  container {
    name   = "keycloak"
    image  = "quay.io/keycloak/keycloak:latest"
    cpu    = 0.5
    memory = 1.0
    
    ports {
      port     = 8080
      protocol = "TCP"
    }
    
    environment_variables = {
      KEYCLOAK_ADMIN          = "admin"
      KC_DB                   = "postgres"
      KC_DB_URL_HOST          = var.postgres_host
      KC_DB_URL_DATABASE      = var.postgres_database
      KC_DB_USERNAME          = var.postgres_username
      KC_HOSTNAME_STRICT      = "false"
      KC_PROXY                = "edge"
    }
    
    secure_environment_variables = {
      KEYCLOAK_ADMIN_PASSWORD = var.keycloak_admin_password
      KC_DB_PASSWORD          = var.postgres_password
    }
  }
  
  # Identity
  identity {
    type = "SystemAssigned"
  }
  
  tags = var.tags
}

# Storage Account (for persistent data)
resource "azurerm_storage_account" "openclaw" {
  name                     = "${var.environment}oclaw${random_string.storage_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = var.tags
}

# Storage Share
resource "azurerm_storage_share" "openclaw" {
  name                 = "openclaw-data"
  storage_account_name = azurerm_storage_account.openclaw.name
  quota                = 10  # 10 GB
}

# Random suffix for storage account (must be globally unique)
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Log Analytics Workspace (for container logs)
resource "azurerm_log_analytics_workspace" "openclaw" {
  name                = "${var.environment}-openclaw-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = var.tags
}

# Diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "openclaw" {
  name                       = "${var.environment}-openclaw-diagnostics"
  target_resource_id         = azurerm_container_group.openclaw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.openclaw.id
  
  log {
    category = "ContainerInstanceLog"
    enabled  = true
    
    retention_policy {
      enabled = true
      days    = 30
    }
  }
  
  metric {
    category = "AllMetrics"
    enabled  = true
    
    retention_policy {
      enabled = true
      days    = 30
    }
  }
}
