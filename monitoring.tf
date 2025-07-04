resource "azurerm_log_analytics_workspace" "security" {
  name = "sc-${var.project}-${var.environment}"  location  = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_security_center_subscription_pricing" "virtual_machines" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_contact" "security_contact" {
  email               = "security@example.com"
  phone               = "+1234567890"
  alert_notifications = true
  alerts_to_admins    = true
}