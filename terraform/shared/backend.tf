# Remote State Backend Configuration
# Storage Account: oclawtfstate67d82d59
# Resource Group: openclaw-tfstate-rg
# Subscription: 05a43f56-f126-4bf1-bb97-9ca4d91dfcb5

terraform {
  backend "azurerm" {
    resource_group_name  = "openclaw-tfstate-rg"
    storage_account_name = "oclawtfstate67d82d59"
    container_name       = "tfstate"
    key                  = "openclaw.tfstate"
    
    # Authentication via Service Principal (environment variables)
    # ARM_CLIENT_ID
    # ARM_CLIENT_SECRET
    # ARM_TENANT_ID
    # ARM_SUBSCRIPTION_ID
  }
}
