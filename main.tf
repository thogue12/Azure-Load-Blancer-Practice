# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.76.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {

  }
}

# Create a resource group

resource "azurerm_resource_group" "resource_group" {
  name     = "tims_rg"
  location = "Eastus"
}

# Create a virtual network within the resource group

resource "azurerm_virtual_network" "vnet" {
  name                = "tims_vnet"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  address_space       = ["10.0.0.0/16"]
}

#create a subnet for the virtual machines
resource "azurerm_subnet" "pub_subnet" {
  name                 = "public_sub"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.resource_group.name
  address_prefixes     = ["10.0.0.0/24"]
}

#association a security group to the virtual virutal machine subnet
resource "azurerm_subnet_network_security_group_association" "pub_nsg_association" {
  subnet_id                 = azurerm_subnet.pub_subnet.id
  network_security_group_id = azurerm_network_security_group.network_sg.id
}

#create the load balancer subnet
resource "azurerm_subnet" "load_balancer_subnet" {
  name                 = "lb_subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.resource_group.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Network Interface for each of the vms
#this one is for vm1
resource "azurerm_network_interface" "network_interface" {
  name                = "backend-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.pub_subnet.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }

}

#network interface for vm2
resource "azurerm_network_interface" "network_interface2" {
  name                = "new_nics2"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal2"
    subnet_id                     = azurerm_subnet.pub_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


#Network security group
resource "azurerm_network_security_group" "network_sg" {
  name                = "allow_web"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "allow_rdp"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_ssh"
    priority                   = 210
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#create the vms and add them to an availability set
#availability set is not necesary but it is posible
#create vm 1 for linux
resource "azurerm_linux_virtual_machine" "linux_vm1" {
  name                  = "linux-vm1"
  resource_group_name   = azurerm_resource_group.resource_group.name
  location              = azurerm_resource_group.resource_group.location
  size                  = "Standard_B2s"
  admin_username        = "vm1"
  network_interface_ids = [azurerm_network_interface.network_interface.id]
  availability_set_id   = azurerm_availability_set.availability_set.id

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
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
  name                  = "linux-vm2"
  resource_group_name   = azurerm_resource_group.resource_group.name
  location              = azurerm_resource_group.resource_group.location
  size                  = "Standard_B2s"
  admin_username        = "vm2"
  network_interface_ids = [azurerm_network_interface.network_interface2.id]
  availability_set_id   = azurerm_availability_set.availability_set.id

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
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

#create the availability set
resource "azurerm_availability_set" "availability_set" {
  name                         = "backend_set"
  location                     = azurerm_resource_group.resource_group.location
  resource_group_name          = azurerm_resource_group.resource_group.name
  managed                      = true
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
  depends_on                   = [azurerm_resource_group.resource_group]

}


#create the control vm and install ansible
#this vm will have ansible installed and will be used to install the different software onto the vms
resource "azurerm_linux_virtual_machine" "control_vm" {
  name                  = "ansible-vm"
  resource_group_name   = azurerm_resource_group.resource_group.name
  location              = azurerm_resource_group.resource_group.location
  size                  = "Standard_B2s"
  admin_username        = "ubuntu"
  network_interface_ids = [azurerm_network_interface.network_interface3.id]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
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



#network interface for ansible vm/ control vm
resource "azurerm_network_interface" "network_interface3" {
  name                = "ansible_nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "ansible_nic"
    subnet_id                     = azurerm_subnet.pub_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ansible_public_ip.id
  }
}

#public ip address for ansible vm
resource "azurerm_public_ip" "ansible_public_ip" {
  name                = "ansible_ip"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}