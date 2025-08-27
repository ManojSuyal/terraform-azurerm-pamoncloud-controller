
#### Set provider
provider "azurerm" {
  features {}
}

#### Create VM resources

resource "azurerm_public_ip" "controller_public_ip" {
  name                = "PAMonCloud-BYOI-Controller-Public-IP"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "controller_network_interface" {
  name                = "Controller-Network-Interface"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.controller_public_ip.id
  }

  depends_on = [azurerm_public_ip.controller_public_ip]
}

# Generate SSH key pair for VM authentication
resource "tls_private_key" "controller_vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key as a file
resource "local_file" "controller_vm_private_key" {
  content         = tls_private_key.controller_vm_ssh_key.private_key_pem
  filename        = "${path.cwd}/controller_vm_private_key.pem"
  file_permission = "0600"
}


resource "azurerm_virtual_machine" "controller_vm" {
  name                          = "PAMonCloudController"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
  network_interface_ids         = [azurerm_network_interface.controller_network_interface.id]
  vm_size                       = var.vm_size
  delete_os_disk_on_termination = true

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]

  }

  storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "controller-osdisk"
    os_type           = "Linux"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = tls_private_key.controller_vm_ssh_key.public_key_openssh
      path     = "/home/${var.vm_admin_user}/.ssh/authorized_keys"
    }
  }

  os_profile {
    computer_name  = "controller"
    admin_username = var.vm_admin_user

    # Run cloud-init script
    custom_data = base64encode(templatefile("${path.module}/files/cloud-init.yaml.tpl", {
      vm_admin_user        = var.vm_admin_user
      storage_account_name = regex("storageAccounts/([^/]+)", var.storage_account_id)[0]
      container_name       = var.container_name
      file_name            = var.file_name
    }))
  }

  tags = {
    Name = "PAMonCloud-BYOI-Controller"
  }
}