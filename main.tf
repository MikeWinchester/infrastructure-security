terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = var.subscription_id
}

# Obtener información del cliente actual
data "azurerm_client_config" "current" {}

# Resource Group principal para seguridad
resource "azurerm_resource_group" "rg_security" {
  name     = "rg-security-${var.project}-${var.environment}"
  location = var.location
  tags     = var.tags
}