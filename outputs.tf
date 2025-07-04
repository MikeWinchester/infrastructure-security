output "key_vault_id" {
  value       = azurerm_key_vault.main.id
  description = "ID of the Key Vault"
  sensitive   = true
}

output "key_vault_uri" {
  value       = azurerm_key_vault.main.vault_uri
  description = "URI of the Key Vault"
}

output "admin_group_id" {
  value       = azuread_group.admin.object_id
  description = "ID of the Admin security group"
}

output "network_security_group_id" {
  value       = azurerm_network_security_group.main.id
  description = "ID of the main Network Security Group"
}

output "service_principal_client_id" {
  value       = azuread_service_principal.ecommerce_sp.client_id
  description = "Client ID of the service principal"
  sensitive   = true
}

output "service_principal_object_id" {
  value       = azuread_service_principal.ecommerce_sp.object_id
  description = "Object ID of the service principal"
  sensitive   = true
}