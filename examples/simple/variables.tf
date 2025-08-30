
variable "subnet_name" {
  description = "Name of the existing subnet"
  type        = string
}

variable "vnet_name" {
  description = "Name of the existing Virtual Network"
  type        = string
}

variable "identity_name" {
  description = "Name of the existing User Assigned Managed Identity"
  type        = string
}

variable "vnet_resource_group_name" {
  description = "The name of the controller's RG"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the controller's RG"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-_.()]{1,89}$", var.resource_group_name))
    error_message = <<-EOF
      The resource group name must meet the following requirements:
        - Be between 1 and 90 characters long.
        - Start with a letter
        - Contain only alphanumeric characters, underscores (_), hyphens (-), or parentheses (()).
    EOF
  }
}

variable "storage_account_id" {
  description = "Resource ID of the storage account containing the BYOI zip"
  type        = string
  validation {
    condition = can(
      regex("^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[a-zA-Z0-9_.-]+/providers/Microsoft.Storage/storageAccounts/[a-z][a-z0-9]{2,23}$", var.storage_account_id)
    )
    error_message = <<-EOF
      The storage_account_id must be a valid Azure storage account resource ID in the following format:
      /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Storage/storageAccounts/{storageAccountName}
    EOF
  }
}

variable "container_name" {
  description = "Name of the storage account container where BYOI zip is stored"
  type        = string
}

variable "file_name" {
  description = "BYOI zip file name to be downloaded from Azure storage account"
  type        = string
  default     = "PAM_Self-Hosted_on_Azure.zip"
}