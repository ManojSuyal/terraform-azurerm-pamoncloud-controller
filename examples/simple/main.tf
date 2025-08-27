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

  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  subnet_id               = var.subnet_id
  identity_id             = var.identity_id
  vm_admin_user           = local.vm_admin_user
  vm_size                 = local.vm_size
  storage_account_id      = var.storage_account_id
  container_name          = var.container_name
  file_name               = var.file_name
}