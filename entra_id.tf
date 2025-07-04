# Azure AD Groups
resource "azuread_group" "admin" {
  display_name     = var.admin_group_name
  security_enabled = true
  mail_enabled     = false
  types            = ["Security"]
}

resource "azuread_group" "user" {
  display_name     = var.user_group_name
  security_enabled = true
  mail_enabled     = false
  types            = ["Security"]
}

# Azure AD Application Registration for e-commerce
resource "azuread_application" "ecommerce_app" {
  display_name = "${var.project}-${var.environment}-app"
  owners       = [data.azurerm_client_config.current.object_id]

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
  }
}

# Azure AD Service Principal for the application
resource "azuread_service_principal" "ecommerce_sp" {
  application_id = azuread_application.ecommerce_app.application_id
  app_role_assignment_required = false
}

# Password para el Service Principal
resource "azuread_service_principal_password" "ecommerce_sp_password" {
  service_principal_id = azuread_service_principal.ecommerce_sp.object_id
}