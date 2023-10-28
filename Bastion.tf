
# #create the subnet to house the Basion host
# resource "azurerm_subnet" "bastion_subnet" {
#   name                 = "AzureBastionSubnet"
#   resource_group_name  = azurerm_resource_group.resource_group.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.2.0/27"]
# }

# #bastion ip
# resource "azurerm_public_ip" "bastion_public_ip" {
#   name                = "bastion_ip"
#   location            = azurerm_resource_group.resource_group.location
#   resource_group_name = azurerm_resource_group.resource_group.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# #bastion host creation
# resource "azurerm_bastion_host" "bastion_host" {
#   name                = "bastion_host"
#   location            = azurerm_resource_group.resource_group.location
#   resource_group_name = azurerm_resource_group.resource_group.name
#   copy_paste_enabled = true
#   sku = "Standard"

#   ip_configuration {
#     name                 = "ip_for_bastion"
#     subnet_id            = azurerm_subnet.bastion_subnet.id
#     public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
#   }
# }
