locals {
  vm_size             = "Standard_D2s_v3"
  vm_admin_user       = "azureadmin"
}

provider "azurerm" {
  features {}
}

################################################################################
# pamoncloud_controller Module
################################################################################
module "pamoncloud_controller" {
  source = "../../"

  resource_group_name = var.resource_group_name
  vnet_name           = var.vnet_name
  subnet_name         = var.subnet_name
  identity_name       = var.identity_name
  vm_admin_user       = local.vm_admin_user
  vm_size             = local.vm_size
  storage_account_id  = var.storage_account_id
  container_name      = var.container_name
  file_name           = var.file_name
}