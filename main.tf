terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

/*
provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}
*/

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project}-${var.environment}-security"
  location = var.location
  tags     = var.tags
}