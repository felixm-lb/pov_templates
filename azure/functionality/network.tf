resource "azurerm_network_security_group" "demo_sg" {
  name = "lb-demo-sg-${random_id.deployment_code.hex}"
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name

  tags = var.tags
}

resource "azurerm_virtual_network" "demo_vnet" {
  name                = "lb-demo-vnet-${random_id.deployment_code.hex}"
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name
  address_space       = var.address_space

  subnet {
    name           = "lb-demo-sn-${random_id.deployment_code.hex}"
    address_prefix = var.address_subnet_space
  }

  tags = var.tags
}

# resource "azurerm_public_ip" "demo_nat_pip" {
#   name                = "lb-demo-natgw_pip-${random_id.deployment_code.hex}"
#   location            = azurerm_resource_group.demo_rg.location
#   resource_group_name = azurerm_resource_group.demo_rg.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   zones               = [var.zone[0]]

#   tags = var.tags
# }

# resource "azurerm_public_ip_prefix" "demo_nat_pip_prefix" {
#   name                = "lb-demo-natgw-pip-prefix-${random_id.deployment_code.hex}"
#   location            = azurerm_resource_group.demo_rg.location
#   resource_group_name = azurerm_resource_group.demo_rg.name
#   prefix_length       = 30
#   zones               = [var.zone[0]]

#   tags = var.tags
# }

resource "azurerm_nat_gateway" "demo_natgw" {
  name                    = "lb-demo-natgw-${random_id.deployment_code.hex}"
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = [var.zone[0]]

  tags = var.tags
}

resource "azurerm_subnet_nat_gateway_association" "example" {
  subnet_id      = azurerm_network_security_group.demo_sg.subnet.id
  nat_gateway_id = azurerm_nat_gateway.demo_natgw.id
}

resource "azurerm_network_security_group" "internet-nsg" {
  name = "lb-demo-nsg-${random_id.deployment_code.hex}"
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name
  security_rule {
    name                       = "allow-internet"
    description                = "allow-internet"
    priority                   = 110
    direction                  = "Outbount"
    access                     = "Allow"
    protocol                   = "Any"
    source_port_range          = "*"
    destination_port_range     = "80,443"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "internet-nsg-association" {
  subnet_id                 = azurerm_virtual_network.demo_vnet.subnet.id
  network_security_group_id = azurerm_network_security_group.internet-nsg.id
}

resource "azurerm_proximity_placement_group" "demo_ppg" {
  name                = "lb-demo-ppg-${random_id.deployment_code.hex}"
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name

  tags = var.tags
}