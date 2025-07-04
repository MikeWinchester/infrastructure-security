output "key_vault_id" {
  value       = azurerm_key_vault.main.id
  description = "ID of the Key Vault"
}

output "key_vault_uri" {
  value       = azurerm_key_vault.main.vault_uri
  description = "URI of the Key Vault"
}

output "network_security_group_id" {
  value       = azurerm_network_security_group.main.id
  description = "ID of the main Network Security Group"
}

output "admin_password_secret_id" {
  value       = azurerm_key_vault_secret.admin_password.id
  description = "ID of the admin password secret in Key Vault"
  sensitive   = true
}