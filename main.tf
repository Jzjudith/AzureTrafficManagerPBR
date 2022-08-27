


# create resource groups
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}


resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet-eastus"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet_uksouth"
  resource_group_name = azurerm_resource_group.main.name
  location            = "UK South"
  address_space       = ["10.0.0.0/16"]
}

# Create Subnets
resource "azurerm_subnet" "sub1" {
  name                 = "private_subnet_eastus"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "agwsub1" {
  name                 = "agw_subnet_eastus"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_subnet" "sub2" {
  name                 = "private_subnet_uksouth"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "agwsub2" {
  name                 = "agw_subnet_uksouth"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.0.4.0/24"]
}


#create network security groups
resource "azurerm_network_security_group" "nsg1" {
  name                = "eastus-nsg"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  security_rule {
    name                       = "Allow-SSH-Access"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16" # "VirtualNetwork"
    destination_port_range     = "22"
  }

  security_rule {
    name                       = "Allow-In-Internet"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "Internet"
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16" # "VirtualNetwork"
    destination_port_range     = "80"
  }
  security_rule {
    name                       = "Allow-Out-Internet"
    priority                   = 103
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.0.0/16"
    source_port_range          = "*"
    destination_address_prefix = "Internet" # 
    destination_port_range     = "80"
  }

  security_rule {
    name                       = "Allow-HttpsIn-Internet"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "Internet"
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16" # "VirtualNetwork"
    destination_port_range     = "443"
  }
  security_rule {
    name                       = "Allow-HttpsOut-Internet"
    priority                   = 105
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.0.0/16"
    source_port_range          = "*"
    destination_address_prefix = "Internet" # 
    destination_port_range     = "443"
  }
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.sub1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_network_security_group" "nsg2" {
  name                = "uksouth-nsg"
  resource_group_name = azurerm_resource_group.main.name
  location            = "UK South"


  security_rule {
    name                       = "Allow-SSH-Access"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16" # "VirtualNetwork"
    destination_port_range     = "22"
  }

  security_rule {
    name                       = "Allow-In-Internet"
    priority                   = 202
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "Internet"
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16" # "VirtualNetwork"
    destination_port_range     = "80"
  }
  security_rule {
    name                       = "Allow-Out-Internet"
    priority                   = 203
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.0.0/16"
    source_port_range          = "*"
    destination_address_prefix = "Internet" # 
    destination_port_range     = "80"
  }

  security_rule {
    name                       = "Allow-HttpsIn-Internet"
    priority                   = 204
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "Internet"
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16" # "VirtualNetwork"
    destination_port_range     = "443"
  }
  security_rule {
    name                       = "Allow-HttpsOut-Internet"
    priority                   = 205
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.0.0/16"
    source_port_range          = "*"
    destination_address_prefix = "Internet"
    destination_port_range     = "443"
  }

  security_rule {
    name                       = "Allow-RDP-In"
    priority                   = 206
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16" #Virtual network
    destination_port_range     = "3389"
  }
}

resource "azurerm_subnet_network_security_group_association" "main2" {
  subnet_id                 = azurerm_subnet.sub2.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}

resource "azurerm_public_ip" "pipeus01" {
  name                = "pip-eastus1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  allocation_method   = "Static"

}

resource "azurerm_public_ip" "pipeus02" {
  name                = "pip-eastus2"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  allocation_method   = "Static"

}

resource "azurerm_public_ip" "pipuks01" {
  name                = "pip-uksouth1"
  resource_group_name = azurerm_resource_group.main.name
  location            = "UK South"
  sku                 = "Standard"
  allocation_method   = "Static"

}


resource "azurerm_public_ip" "pipuks02" {
  name                = "pip-uksouth2"
  resource_group_name = azurerm_resource_group.main.name
  location            = "UK South"
  sku                 = "Standard"
  allocation_method   = "Static"

}
#create network interface
resource "azurerm_network_interface" "nic01" {
  name                = "eastus-nic01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "eastus-ipconfig"
    subnet_id                     = azurerm_subnet.sub1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pipeus01.id
  }
}

resource "azurerm_network_interface" "nic02" {
  name                = "eastus-nic02"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "eastus-ipconfig2"
    subnet_id                     = azurerm_subnet.sub1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pipeus02.id
  }
}

resource "azurerm_network_interface" "nic03" {
  name                = "uksouth-nic03"
  location            = "UK South"
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "uksouth-ipconfig"
    subnet_id                     = azurerm_subnet.sub2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pipuks01.id
  }
}

resource "azurerm_network_interface" "nic04" {
  name                = "uksouth-nic04"
  location            = "UK South"
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "uksouth-ipconfig2"
    subnet_id                     = azurerm_subnet.sub2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pipuks02.id
  }
}

#create virtual machines
resource "azurerm_linux_virtual_machine" "main" {
  name                  = "vm-eastus1"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "Standard_B2ms"
  admin_username        = "devlab"
  admin_password        = "Password123"
  network_interface_ids = [azurerm_network_interface.nic01.id, ]


  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }



}

resource "azurerm_linux_virtual_machine" "main2" {
  name                  = "vm-eastus2"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "Standard_B2ms"
  admin_username        = "devlab"
  admin_password        = "Password123"
  network_interface_ids = [azurerm_network_interface.nic02.id, ]


  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }



}

resource "azurerm_windows_virtual_machine" "main" {
  name                = "vm-uksouth1"
  resource_group_name = azurerm_resource_group.main.name
  location            = "UK South"
  size                = "Standard_F2"
  admin_username      = "devlab"
  admin_password      = "Password123"
  network_interface_ids = [
    azurerm_network_interface.nic03.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }


}

resource "azurerm_windows_virtual_machine" "main2" {
  name                = "vm-uksouth2"
  resource_group_name = azurerm_resource_group.main.name
  location            = "UK South"
  size                = "Standard_F2"
  admin_username      = "devlab"
  admin_password      = "Password123"
  network_interface_ids = [
    azurerm_network_interface.nic04.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }


}