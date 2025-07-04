variable "subscription_id" {
  type        = string
  description = "The azure subscription id"
}

variable "location" {
  type        = string
  description = "The azure region to deploy"
  default     = "Central US"
}

variable "project" {
  type        = string
  description = "The name of the project"
  default     = "ecommerce"
}

variable "environment" {
  type        = string
  description = "The environment to deploy"
  default     = "dev"
}

variable "tags" {
  type        = map(string)
  description = "maps of tags"
  default = {
    "environment" = "development"
    date          = "july-2025"
    createdby     = "terraform"
    module        = "security"
  }
}

variable "allowed_ips" {
  type        = list(string)
  description = "List of allowed IPs for Key Vault access"
  default     = []
}

variable "ssl_certificate_name" {
  type        = string
  description = "Name for SSL certificate"
  default     = "ecommerce-ssl-cert"
}

variable "custom_domain" {
  type        = string
  description = "Custom domain for the application"
  default     = ""
}

variable "key_vault_sku" {
  type        = string
  description = "SKU for Key Vault"
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be 'standard' or 'premium'."
  }
}

variable "network_security_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  description = "List of network security rules"
  default = []
}