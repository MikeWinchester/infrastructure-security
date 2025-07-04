variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID"
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
  description = "Map of tags"
  default = {
    "environment" = "development"
    "createdby"   = "terraform"
  }
}

variable "allowed_ips" {
  type        = list(string)
  description = "List of allowed IP addresses for admin access"
  default     = ["192.168.1.1/32"] # Reemplaza con tus IPs reales
}

variable "admin_username" {
  type        = string
  description = "Admin username for resources"
  default     = "adminuser"
}