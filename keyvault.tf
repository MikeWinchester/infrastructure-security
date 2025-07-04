#-------------------------------#
# Key Vault para secretos y certificados
#-------------------------------#

resource "azurerm_key_vault" "main" {
  name                = "kv-${var.project}-${var.environment}"
  location            = azurerm_resource_group.rg_security.location
  resource_group_name = azurerm_resource_group.rg_security.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.key_vault_sku

  # Configuración de acceso
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = false
  soft_delete_retention_days      = 7

  # Política de acceso por defecto para el service principal actual
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "List",
      "Delete",
      "Update",
      "Recover",
      "Purge"
    ]

    secret_permissions = [
      "Set",
      "Get",
      "List",
      "Delete",
      "Recover",
      "Purge"
    ]

    certificate_permissions = [
      "Create",
      "Get",
      "List",
      "Delete",
      "Update",
      "Import",
      "Recover",
      "Purge"
    ]
  }

  # Configuración de red (permisiva para desarrollo)
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
    
    # Solo aplicar restricciones si se proporcionan IPs específicas
    ip_rules = length(var.allowed_ips) > 0 ? var.allowed_ips : []
  }

  tags = var.tags
}

# Secretos esenciales para la aplicación
resource "azurerm_key_vault_secret" "database_connection_string" {
  name         = "database-connection-string"
  value        = "Server=tcp:${var.project}-${var.environment}.database.windows.net,1433;Initial Catalog=${var.project}db;Persist Security Info=False;User ID=admin;Password=CHANGE_ME;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.main.id
  
  tags = var.tags
  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "api_key" {
  name         = "api-key"
  value        = "your-api-key-here"
  key_vault_id = azurerm_key_vault.main.id
  
  tags = var.tags
  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = "jwt-secret"
  value        = "your-jwt-secret-key-here"
  key_vault_id = azurerm_key_vault.main.id
  
  tags = var.tags
  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "storage_connection_string" {
  name         = "storage-connection-string"
  value        = "DefaultEndpointsProtocol=https;AccountName=st${var.project}${var.environment};AccountKey=CHANGE_ME;EndpointSuffix=core.windows.net"
  key_vault_id = azurerm_key_vault.main.id
  
  tags = var.tags
  depends_on = [azurerm_key_vault.main]
}

# Certificado SSL auto-firmado (para desarrollo)
resource "azurerm_key_vault_certificate" "ssl_cert" {
  name         = var.ssl_certificate_name
  key_vault_id = azurerm_key_vault.main.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = var.custom_domain != "" ? [var.custom_domain] : ["${var.project}-${var.environment}.azurewebsites.net"]
      }

      subject            = "CN=${var.custom_domain != "" ? var.custom_domain : "${var.project}-${var.environment}.azurewebsites.net"}"
      validity_in_months = 12
    }
  }

  tags = var.tags
  depends_on = [azurerm_key_vault.main]
}