# Create Traffic Manager  Profile
# resource "random_id" "server" {
#   keepers = {
#     azi_id = 1
#   }

#   byte_length = 8
# }


resource "azurerm_traffic_manager_profile" "global" {
  name                   = "dev-lab-tfc-mgr"
  resource_group_name    = azurerm_resource_group.main.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "dev-lab-tfc-mgr"
    ttl           = 300
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

  tags = {
    environment = "Development"
  }
}

# Querying public ip addresses
data "azurerm_public_ip" "pip01" {
  name                = "pip-eastus"
  resource_group_name = azurerm_resource_group.main.name
}
data "azurerm_public_ip" "pip02" {
  name                = "pip-uksouth"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_traffic_manager_azure_endpoint" "main" {
  name               = "eastus-endpoint"
  profile_id         = azurerm_traffic_manager_profile.global.id
  target_resource_id = azurerm_public_ip.pip01.id
  weight             = 100
  depends_on = [
    data.azurerm_public_ip.pip01
  ]
}

resource "azurerm_traffic_manager_azure_endpoint" "main2" {
  name               = "uksouth-endpoint"
  profile_id         = azurerm_traffic_manager_profile.global.id
  target_resource_id = azurerm_public_ip.pip02.id
  weight             = 100

  depends_on = [
    data.azurerm_public_ip.pip02
  ]
}

