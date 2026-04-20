variable "prefix" {
  type        = string
  description = "Short prefix used for all resource names (e.g. 'openclaw')"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "dns_label" {
  type        = string
  description = "DNS label for the public IP (must be globally unique within the region)"
  default     = "openclaw"
}

variable "ssh_source_cidr" {
  type        = string
  description = "CIDR allowed to reach the VM on port 22. Use your own IP (x.x.x.x/32) for tighter security."
  default     = "*"
}

variable "tags" {
  type    = map(string)
  default = {}
}
