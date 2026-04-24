# Development Environment
# Minimal cost configuration for testing

terraform {
  backend "azurerm" {
    resource_group_name  = "openclaw-tfstate-rg"
    storage_account_name = "oclawtfstate67d82d59"
    container_name       = "tfstate"
    key                  = "openclaw-dev.tfstate"
  }
}

# Include shared provider configuration
module "shared_config" {
  source = "../../shared"
  
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  
  environment  = "dev"
  location     = var.location
  project_name = "openclaw"
  
  tags = merge(
    var.tags,
    {
      Environment = "Development"
      CostCenter  = "Engineering"
    }
  )
}

# Resource Group
resource "azurerm_resource_group" "openclaw_dev" {
  name     = "openclaw-dev-rg"
  location = var.location
  
  tags = module.shared_config.tags
}

# OpenClaw VM Module (Cheapest option for dev)
module "openclaw_vm" {
  source = "../../modules/openclaw-vm"
  
  environment         = "dev"
  resource_group_name = azurerm_resource_group.openclaw_dev.name
  location            = azurerm_resource_group.openclaw_dev.location
  
  # Cost optimization for dev
  vm_size              = "Standard_B1s"  # Cheapest: ~$8/mo
  admin_username       = var.admin_username
  ssh_public_key       = var.ssh_public_key
  enable_auto_shutdown = true             # Shut down at night
  auto_shutdown_time   = "2300"           # 11 PM
  
  # OpenClaw configuration
  agents_count     = 9
  github_token     = var.github_token
  copilot_token    = var.copilot_token
  domain_label     = "openclaw-dev-${random_string.suffix.result}"
  
  tags = module.shared_config.tags
}

# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
