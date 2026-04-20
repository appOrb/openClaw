variable "prefix" {
  type        = string
  description = "Short prefix for resource names"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "vm_size" {
  type        = string
  description = "Azure VM SKU"
  default     = "Standard_B2s"
}

variable "admin_username" {
  type        = string
  description = "Admin username on the VM"
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key content (e.g. file('~/.ssh/id_rsa.pub'))"
  sensitive   = true
}

variable "nic_id" {
  type        = string
  description = "Network interface ID from the networking module"
}

variable "tags" {
  type    = map(string)
  default = {}
}
