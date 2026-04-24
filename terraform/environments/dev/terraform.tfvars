# Development Environment Variables

# Azure Authentication (via Service Principal)
subscription_id = "05a43f56-f126-4bf1-bb97-9ca4d91dfcb5"
tenant_id       = "1b9184b9-e785-4727-a33d-f9526fe07006"
client_id       = "f2410d10-07d1-49e2-af61-dba86cc9b441"
# client_secret - set via TF_VAR_client_secret environment variable

# Azure Region
location = "eastus"

# VM Configuration
admin_username = "azureuser"
# ssh_public_key - set via TF_VAR_ssh_public_key environment variable

# OpenClaw Configuration  
# github_token - set via TF_VAR_github_token environment variable
# copilot_token - set via TF_VAR_copilot_token environment variable

# Tags
tags = {
  Project     = "OpenClaw"
  Environment = "Development"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
  Owner       = "reevelobo"
}
