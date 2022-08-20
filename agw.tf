
# create dynamic public ip addresses
resource "azurerm_public_ip" "pip01" {
  name                = "pip-eastus"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = "ivenicorp"
}

resource "azurerm_public_ip" "pip02" {
  name                = "pip-uksouth"
  resource_group_name = azurerm_resource_group.main.name
  location            = "UK South"
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = "ivenicorp"
}


locals {
  backend_address_pool_name      = "${azurerm_virtual_network.vnet1.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.vnet1.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet1.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.vnet1.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.vnet1.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet1.name}-rqrt"
}

resource "azurerm_application_gateway" "network" {
  name                = "eastus-appgateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "eastus-agw-ip-config"
    subnet_id = azurerm_subnet.agwsub1.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip01.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    priority                   = 25
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}


resource "azurerm_application_gateway" "network2" {
  name                = "uksouth-appgateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = "UK South"

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "uksouth-agw-ip-config"
    subnet_id = azurerm_subnet.agwsub2.id
  }

  frontend_port {
    name = "uksouth_frontend_port_name"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "uksouth_frontend_ip_configuration_name"
    public_ip_address_id = azurerm_public_ip.pip02.id
  }

  backend_address_pool {
    name = "uksouth_backend_address_pool_name"
  }

  backend_http_settings {
    name                  = "uksouth_http_setting_name"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = "uksouth_listener_name"
    frontend_ip_configuration_name = "uksouth_frontend_ip_configuration_name"
    frontend_port_name             = "uksouth_frontend_port_name"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    priority                   = 25
    http_listener_name         = "uksouth_listener_name"
    backend_address_pool_name  = "uksouth_backend_address_pool_name"
    backend_http_settings_name = "uksouth_http_setting_name"
  }
}


resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "main" {
  network_interface_id    = azurerm_network_interface.nic01.id
  ip_configuration_name   = "eastus-ipconfig"
  backend_address_pool_id = tolist(azurerm_application_gateway.network.backend_address_pool).0.id
}



resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "main2" {
  network_interface_id    = azurerm_network_interface.nic02.id
  ip_configuration_name   = "eastus-ipconfig2"
  backend_address_pool_id = tolist(azurerm_application_gateway.network.backend_address_pool).0.id
}



resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "main3" {
  network_interface_id    = azurerm_network_interface.nic03.id
  ip_configuration_name   = "uksouth-ipconfig"
  backend_address_pool_id = tolist(azurerm_application_gateway.network2.backend_address_pool).0.id
}



resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "main4" {
  network_interface_id    = azurerm_network_interface.nic04.id
  ip_configuration_name   = "uksouth-ipconfig2"
  backend_address_pool_id = tolist(azurerm_application_gateway.network2.backend_address_pool).0.id
}