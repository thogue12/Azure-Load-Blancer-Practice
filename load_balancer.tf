
#create the public Ip for the load balancer
resource "azurerm_public_ip" "public_ip" {
  name                = "lb-ip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#create the load balancer
resource "azurerm_lb" "load_balancer" {
  name                = "terraform_lb"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "Public-ip"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }


  depends_on = [azurerm_public_ip.public_ip]
}

#load balancer rule
resource "azurerm_lb_rule" "load_balance_rule" {
  loadbalancer_id                = azurerm_lb.load_balancer.id
  name                           = "HttpRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "Public-ip"
  probe_id                       = azurerm_lb_probe.load_balancer_prob.id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.backend_pool.id]
  depends_on = [azurerm_lb.load_balancer,
    azurerm_lb_probe.load_balancer_prob
  ]
}

#load balancer probe
resource "azurerm_lb_probe" "load_balancer_prob" {
  loadbalancer_id = azurerm_lb.load_balancer.id
  name            = "http-probe"
  port            = 80
  protocol        = "Http"
  probe_threshold = "5"
  request_path    = "/"
  depends_on      = [azurerm_lb.load_balancer]
}

#Backend address pool
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.load_balancer.id
  name            = "terraform_backend"

  depends_on = [azurerm_lb.load_balancer]
}



#associate the NIC of VM1 to the backend pool
resource "azurerm_network_interface_backend_address_pool_association" "vm1_nic_backend" {
  network_interface_id    = azurerm_network_interface.network_interface.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}


#associate the NIC of VM2 to the backend pool
resource "azurerm_network_interface_backend_address_pool_association" "vm2_nic_backend" {
  network_interface_id    = azurerm_network_interface.network_interface2.id
  ip_configuration_name   = "internal2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}

