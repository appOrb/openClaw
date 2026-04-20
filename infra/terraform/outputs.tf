output "public_ip_address" {
  description = "Static public IP of the VM"
  value       = module.networking.public_ip_address
}

output "fqdn" {
  description = "Fully-qualified domain name assigned to the public IP"
  value       = module.networking.fqdn
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${module.networking.public_ip_address}"
}

output "copilot_auth_command" {
  description = "Run this on the VM after provisioning to authenticate GitHub Copilot"
  value       = "ssh ${var.admin_username}@${module.networking.public_ip_address} 'openclaw models auth login-github-copilot'"
}

output "paperclip_url" {
  description = "Paperclip UI (accessible once Nginx + SSL are configured)"
  value       = "https://${module.networking.fqdn}"
}
