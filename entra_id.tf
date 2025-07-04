# Azure AD Groups
resource "azurerm_ad_group" "admin" {
  display_name     = var.admin_group_name
  security_enabled = true
}

resource "azurerm_ad_group" "user" {
  display_name     = var.user_group_name
  security_enabled = true
}

# Azure AD Application Registration for e-commerce
resource "azurerm_ad_application" "ecommerce_app" {
  display_name = "${var.project}-${var.environment}-app"
  owners       = [data.azurerm_client_config.current.object_id]
}

# Azure AD Service Principal for the application
resource "azurerm_ad_service_principal" "ecommerce_sp" {
  application_id = azurerm_ad_application.ecommerce_app.application_id
}

# Conditional Access Policy (example)
resource "azurerm_ad_conditional_access_policy" "mfa_policy" {
  display_name = "Require MFA for Admin Access"
  state        = "enabled"

  conditions {
    applications {
      included_applications = ["All"]
    }

    users {
      included_users = ["All"]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

data "azurerm_client_config" "current" {}