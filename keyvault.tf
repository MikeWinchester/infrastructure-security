resource "azurerm_key_vault" "main" {
  name = "kv-${var.project}-${var.environment}-${substr(lower(replace(data.azurerm_client_config.current.subscription_id, "-", "")), 0, 8)}"  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Recover", "Backup", "Restore"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    #ip_rules       = var.allowed_ips
  }

  tags = var.tags
}

resource "azurerm_key_vault_secret" "admin_password" {
  name         = "admin-password"
  value        = random_password.admin.result
  key_vault_id = azurerm_key_vault.main.id
}

resource "random_password" "admin" {
  length           = 16
  special          = true
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}