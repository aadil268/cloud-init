variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-cloudinit-test"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}