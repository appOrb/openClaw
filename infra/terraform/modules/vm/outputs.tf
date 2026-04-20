output "vm_id" {
  value = azurerm_linux_virtual_machine.this.id
}

output "private_ip_address" {
  value = azurerm_linux_virtual_machine.this.private_ip_address
}
