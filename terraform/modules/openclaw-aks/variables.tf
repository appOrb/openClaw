# OpenClaw AKS Module Variables

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "system_node_count" {
  description = "System node pool initial count"
  type        = number
  default     = 3
}

variable "system_node_size" {
  description = "System node VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "system_node_min_count" {
  description = "System node pool min count"
  type        = number
  default     = 1
}

variable "system_node_max_count" {
  description = "System node pool max count"
  type        = number
  default     = 5
}

variable "user_node_count" {
  description = "User node pool initial count"
  type        = number
  default     = 3
}

variable "user_node_size" {
  description = "User node VM size"
  type        = string
  default     = "Standard_B4ms"
}

variable "user_node_min_count" {
  description = "User node pool min count"
  type        = number
  default     = 2
}

variable "user_node_max_count" {
  description = "User node pool max count"
  type        = number
  default     = 10
}

variable "admin_group_ids" {
  description = "AAD admin group object IDs"
  type        = list(string)
  default     = []
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy addon"
  type        = bool
  default     = true
}

variable "enable_agic" {
  description = "Enable Application Gateway Ingress Controller"
  type        = bool
  default     = false
}

variable "application_gateway_id" {
  description = "Application Gateway ID for AGIC"
  type        = string
  default     = ""
}

variable "geo_replications" {
  description = "ACR geo-replication locations"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
