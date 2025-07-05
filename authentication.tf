#-------------------------------#
# Configuración de autenticación
#-------------------------------#

# Managed Identity para el proyecto (reemplaza parte de Azure AD)
resource "azurerm_user_assigned_identity" "main" {
  name                = "id-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg_security.name
  location            = azurerm_resource_group.rg_security.location

  tags = var.tags
}

# Storage Account para configuraciones de usuarios y sesiones
resource "azurerm_storage_account" "auth_storage" {
  name                     = "stauth${var.project}${var.environment}"
  resource_group_name      = azurerm_resource_group.rg_security.name
  location                 = azurerm_resource_group.rg_security.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Configuración de seguridad
  # enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"
  allow_nested_items_to_be_public = false

  # Configuración de red
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    
    # Permitir acceso desde las subnets del proyecto
    virtual_network_subnet_ids = [
      azurerm_subnet.web.id,
      azurerm_subnet.data.id
    ]
  }

  tags = var.tags
}

# Logic App para manejo de autenticación personalizada
resource "azurerm_logic_app_workflow" "auth_service" {
  name                = "auth-service-${var.project}-${var.environment}"
  location            = azurerm_resource_group.rg_security.location
  resource_group_name = azurerm_resource_group.rg_security.name

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  tags = var.tags
}

# Dar acceso a la Managed Identity sobre el Key Vault
resource "azurerm_key_vault_access_policy" "managed_identity" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.main.principal_id

  secret_permissions = [
    "Get",
    "List",
    "Set"
  ]

  certificate_permissions = [
    "Get",
    "List"
  ]
}

# Dar acceso a la Managed Identity sobre el Storage Account
resource "azurerm_role_assignment" "storage_access" {
  scope                = azurerm_storage_account.auth_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# # Secretos específicos para autenticación
# resource "azurerm_key_vault_secret" "auth_encryption_key" {
#   name         = "auth-encryption-key"
#   value        = "your-encryption-key-for-passwords"
#   key_vault_id = azurerm_key_vault.main.id
  
  
#   tags = var.tags
#   depends_on = [azurerm_key_vault.main]
# }

# resource "azurerm_key_vault_secret" "session_secret" {
#   name         = "session-secret"
#   value        = "your-session-secret-key"
#   key_vault_id = azurerm_key_vault.main.id
  
#   tags = var.tags
#   depends_on = [azurerm_key_vault.main]
# }

# # OAuth/External provider secrets (Google, Facebook, etc.)
# resource "azurerm_key_vault_secret" "google_oauth_client_id" {
#   name         = "google-oauth-client-id"
#   value        = "your-google-oauth-client-id"
#   key_vault_id = azurerm_key_vault.main.id
  
#   tags = var.tags
#   depends_on = [azurerm_key_vault.main]
# }

# resource "azurerm_key_vault_secret" "google_oauth_client_secret" {
#   name         = "google-oauth-client-secret"
#   value        = "your-google-oauth-client-secret"
#   key_vault_id = azurerm_key_vault.main.id
  
#   tags = var.tags
#   depends_on = [azurerm_key_vault.main]
# }