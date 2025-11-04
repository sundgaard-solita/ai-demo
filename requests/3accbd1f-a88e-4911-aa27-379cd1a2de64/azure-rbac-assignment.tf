# Azure RBAC Role Assignment for RIT5 Resource Group
# Request ID: 3accbd1f-a88e-4911-aa27-379cd1a2de64
# Requested by: Michael Ringholm Sundgaard
# Date: 2025-11-04

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "principal_id" {
  description = "The principal ID (Object ID) of user MRS"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "RIT5"
}

variable "role_name" {
  description = "The role to assign (Reader, Contributor, or Owner)"
  type        = string
  default     = "Contributor"
  
  validation {
    condition     = contains(["Reader", "Contributor", "Owner"], var.role_name)
    error_message = "Role must be Reader, Contributor, or Owner"
  }
}

data "azurerm_resource_group" "rit5" {
  name = var.resource_group_name
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "mrs_rit5" {
  scope                = data.azurerm_resource_group.rit5.id
  role_definition_name = var.role_name
  principal_id         = var.principal_id
  
  # Ensure assignment is tracked for compliance
  description = "Access granted via request 3accbd1f-a88e-4911-aa27-379cd1a2de64 on 2025-11-04"
}

output "role_assignment_id" {
  description = "The ID of the role assignment"
  value       = azurerm_role_assignment.mrs_rit5.id
}

output "assigned_role" {
  description = "The role that was assigned"
  value       = var.role_name
}

output "resource_group" {
  description = "The resource group where access was granted"
  value       = var.resource_group_name
}

output "principal_id" {
  description = "The principal ID that was granted access"
  value       = var.principal_id
}
