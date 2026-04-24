# OpenClaw VM Module Outputs

output "vm_id" {
  description = "Virtual Machine ID"
  value       = azurerm_linux_virtual_machine.openclaw.id
}

output "vm_name" {
  description = "Virtual Machine name"
  value       = azurerm_linux_virtual_machine.openclaw.name
}

output "public_ip_address" {
  description = "Public IP address"
  value       = azurerm_public_ip.openclaw.ip_address
}

output "public_fqdn" {
  description = "Public fully qualified domain name"
  value       = azurerm_public_ip.openclaw.fqdn
}

output "private_ip_address" {
  description = "Private IP address"
  value       = azurerm_network_interface.openclaw.private_ip_address
}

output "ssh_command" {
  description = "SSH command to connect to VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.openclaw.ip_address}"
}

output "openclaw_url" {
  description = "OpenClaw web interface URL"
  value       = "https://${azurerm_public_ip.openclaw.fqdn}"
}

output "resource_group_name" {
  description = "Resource group name"
  value       = var.resource_group_name
}
