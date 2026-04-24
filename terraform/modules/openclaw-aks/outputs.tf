# OpenClaw AKS Module Outputs

output "cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.openclaw.id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.openclaw.name
}

output "cluster_fqdn" {
  description = "AKS cluster FQDN"
  value       = azurerm_kubernetes_cluster.openclaw.fqdn
}

output "kube_config" {
  description = "Kubernetes config"
  value       = azurerm_kubernetes_cluster.openclaw.kube_config_raw
  sensitive   = true
}

output "kubelet_identity" {
  description = "Kubelet managed identity"
  value       = azurerm_kubernetes_cluster.openclaw.kubelet_identity[0].object_id
}

output "acr_id" {
  description = "Container Registry ID"
  value       = azurerm_container_registry.openclaw.id
}

output "acr_login_server" {
  description = "Container Registry login server"
  value       = azurerm_container_registry.openclaw.login_server
}

output "ingress_ip" {
  description = "Ingress public IP address"
  value       = azurerm_public_ip.ingress.ip_address
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.openclaw.id
}
