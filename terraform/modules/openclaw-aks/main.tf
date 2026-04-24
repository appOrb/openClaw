# OpenClaw AKS (Azure Kubernetes Service) Module
# Production-grade Kubernetes deployment

# AKS Cluster
resource "azurerm_kubernetes_cluster" "openclaw" {
  name                = "${var.environment}-openclaw-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.environment}-openclaw"
  kubernetes_version  = var.kubernetes_version
  
  # Default node pool
  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = var.system_node_size
    type                = "VirtualMachineScaleSets"
    availability_zones  = ["1", "2", "3"]
    enable_auto_scaling = true
    min_count           = var.system_node_min_count
    max_count           = var.system_node_max_count
    
    # Node labels
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "role"          = "system"
    }
    
    # Node taints for system workloads
    node_taints = []
  }
  
  # Identity
  identity {
    type = "SystemAssigned"
  }
  
  # Network profile
  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
    service_cidr       = "10.1.0.0/16"
    dns_service_ip     = "10.1.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }
  
  # RBAC & AAD integration
  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_ids
  }
  
  # Add-ons
  addon_profile {
    # Azure Monitor
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.openclaw.id
    }
    
    # Azure Policy
    azure_policy {
      enabled = var.enable_azure_policy
    }
    
    # Ingress Application Gateway
    dynamic "ingress_application_gateway" {
      for_each = var.enable_agic ? [1] : []
      content {
        enabled    = true
        gateway_id = var.application_gateway_id
      }
    }
  }
  
  # Auto-scaler profile
  auto_scaler_profile {
    balance_similar_node_groups      = true
    max_graceful_termination_sec     = 600
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "10s"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = 0.5
  }
  
  # Maintenance window
  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [2, 3, 4]
    }
  }
  
  tags = var.tags
}

# User node pool (for OpenClaw workloads)
resource "azurerm_kubernetes_cluster_node_pool" "openclaw" {
  name                  = "openclaw"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.openclaw.id
  vm_size               = var.user_node_size
  node_count            = var.user_node_count
  availability_zones    = ["1", "2", "3"]
  enable_auto_scaling   = true
  min_count             = var.user_node_min_count
  max_count             = var.user_node_max_count
  
  node_labels = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "workload"      = "openclaw"
  }
  
  tags = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "openclaw" {
  name                = "${var.environment}-openclaw-aks-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  
  tags = var.tags
}

# Container Registry (for OpenClaw images)
resource "azurerm_container_registry" "openclaw" {
  name                = "${var.environment}oclawacr${random_string.acr_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
  
  # Geo-replication for production
  dynamic "georeplications" {
    for_each = var.environment == "production" ? var.geo_replications : []
    content {
      location = georeplications.value
      tags     = var.tags
    }
  }
  
  tags = var.tags
}

# ACR role assignment (allow AKS to pull images)
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.openclaw.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.openclaw.id
}

# Random suffix for ACR (globally unique)
resource "random_string" "acr_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Public IP for ingress
resource "azurerm_public_ip" "ingress" {
  name                = "${var.environment}-openclaw-ingress-ip"
  location            = var.location
  resource_group_name = azurerm_kubernetes_cluster.openclaw.node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = var.tags
}

# Storage Class for persistent volumes
resource "kubernetes_storage_class" "openclaw" {
  metadata {
    name = "openclaw-storage"
  }
  
  storage_provisioner = "kubernetes.io/azure-disk"
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
  
  parameters = {
    storageaccounttype = "StandardSSD_LRS"
    kind               = "Managed"
    cachingmode        = "ReadOnly"
  }
}
