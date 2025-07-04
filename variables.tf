variable "subscription_id" {
  type        = string
  description = "The Azure subscription id"
}

variable "location" {
  type        = string
  description = "The Azure region to deploy"
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
    date = "july-2025"
    createdby = "terraform"
  }
}

variable "domain_name" {
  type        = string
  description = "Custom domain name for the e-commerce site"
}

variable "admin_group_name" {
  type        = string
  description = "Name for the admin security group"
  default     = "Ecommerce-Admins"
}

variable "user_group_name" {
  type        = string
  description = "Name for the user security group"
  default     = "Ecommerce-Users"
}

variable "key_vault_sku" {
  type        = string
  description = "SKU for Key Vault"
  default     = "standard"
}