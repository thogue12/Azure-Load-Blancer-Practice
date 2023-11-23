#create the vms and add them to an availability set
#availability set is not necesary but it is posible
#create vm 1 for linux
resource "azurerm_linux_virtual_machine" "linux_vm1" {
  name                  = var.vm1_name
  resource_group_name   = azurerm_resource_group.resource_group.name 
  location              = azurerm_resource_group.resource_group.location
  size                  = "Standard_B2s"
  admin_username        = "vm"
  network_interface_ids = [azurerm_network_interface.network_interface.id]
  user_data             = base64encode(templatefile("install_apache.tftpl", local.data_inputs))


  admin_ssh_key {
    username   = "vm"
    public_key = file("AzureLoadBalancer.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

}


#create vm 2 linux os
resource "azurerm_linux_virtual_machine" "linux_vm2" {
  name                  = var.vm2_name
  resource_group_name   = azurerm_resource_group.resource_group.name
  location              = azurerm_resource_group.resource_group.location
  size                  = "Standard_B2s"
  admin_username        = "vm"
  network_interface_ids = [azurerm_network_interface.network_interface2.id]
  user_data             = base64encode(templatefile("install_apache.tftpl", local.data_inputs))


  admin_ssh_key {
    username   = "vm"
    public_key = file("AzureLoadBalancer.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}


# #create control vm ansible
resource "azurerm_linux_virtual_machine" "caontrol_vm" {
  name                  = var.control_vm
  resource_group_name   = azurerm_resource_group.resource_group.name
  location              = azurerm_resource_group.resource_group.location
  size                  = "Standard_B2s"
  admin_username        = "vm"
  network_interface_ids = [azurerm_network_interface.network_interface3.id]
  user_data             = base64encode(templatefile("install_apache.tftpl", local.data_inputs))


  admin_ssh_key {
    username   = "vm"
    public_key = file("AzureLoadBalancer.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
