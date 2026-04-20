terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }

  # Remote state — shared between local dev and GitHub Actions CI/CD.
  # Storage account created by: az storage account create ...
  # Credentials come from ARM_* env vars (local: az login, CI: service principal secrets).
  backend "azurerm" {
    resource_group_name  = "openclaw-tfstate-rg"
    storage_account_name = "oclawtfstate67d82d59"
    container_name       = "tfstate"
    key                  = "openclaw/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
