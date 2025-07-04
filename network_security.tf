#-------------------------------#
# Network Security Groups y reglas de firewall
#-------------------------------#

# Virtual Network para el proyecto
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project}-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_security.location
  resource_group_name = azurerm_resource_group.rg_security.name

  tags = var.tags
}

# Subnet para aplicaciones web
resource "azurerm_subnet" "web" {
  name                 = "subnet-web-${var.project}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg_security.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Subnet para bases de datos
resource "azurerm_subnet" "data" {
  name                 = "subnet-data-${var.project}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg_security.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group para aplicaciones web
resource "azurerm_network_security_group" "web_nsg" {
  name                = "nsg-web-${var.project}-${var.environment}"
  location            = azurerm_resource_group.rg_security.location
  resource_group_name = azurerm_resource_group.rg_security.name

  # Regla para permitir tráfico HTTP
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Regla para permitir tráfico HTTPS
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Regla para denegar todo el tráfico SSH por defecto
  security_rule {
    name                       = "DenySSH"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Regla para denegar RDP
  security_rule {
    name                       = "DenyRDP"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Network Security Group para bases de datos
resource "azurerm_network_security_group" "data_nsg" {
  name                = "nsg-data-${var.project}-${var.environment}"
  location            = azurerm_resource_group.rg_security.location
  resource_group_name = azurerm_resource_group.rg_security.name

  # Permitir tráfico desde subnet web a SQL Server
  security_rule {
    name                       = "AllowWebToSQL"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  # Denegar todo el tráfico externo
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Reglas de seguridad personalizadas (si se proporcionan)
resource "azurerm_network_security_rule" "custom_rules" {
  count = length(var.network_security_rules)

  name                        = var.network_security_rules[count.index].name
  priority                    = var.network_security_rules[count.index].priority
  direction                   = var.network_security_rules[count.index].direction
  access                      = var.network_security_rules[count.index].access
  protocol                    = var.network_security_rules[count.index].protocol
  source_port_range           = var.network_security_rules[count.index].source_port_range
  destination_port_range      = var.network_security_rules[count.index].destination_port_range
  source_address_prefix       = var.network_security_rules[count.index].source_address_prefix
  destination_address_prefix  = var.network_security_rules[count.index].destination_address_prefix
  resource_group_name         = azurerm_resource_group.rg_security.name
  network_security_group_name = azurerm_network_security_group.web_nsg.name
}

# Asociar NSG con subnets
resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data_nsg.id
}

# Web Application Firewall (WAF) Policy
resource "azurerm_web_application_firewall_policy" "main" {
  name                = "waf-policy-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg_security.name
  location            = azurerm_resource_group.rg_security.location

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  tags = var.tags
}