resource "azurerm_resource_group" "rg1" {
  name     = "jclishe-rg-01-tf"
  location = "East US"
  tags = {
    owner = var.tag-owner
  }
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "jclishe-nsg-01-tf"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  security_rule {
    name                       = "AllowSSHInBound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPInBound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPSInBound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    "owner" = var.tag-owner
  }
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "jclishe-vnet-77-tf"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = ["10.77.0.0/16"]

  tags = {
    "owner" = var.tag-owner
  }
}

resource "azurerm_subnet" "subnet1" {
  name                 = "jclishe-subnet-77-01-tf"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.77.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "jclishe-subnet-77-02-tf"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.77.2.0/24"]
}

resource "azurerm_public_ip" "publicip1" {
  name                = "jclishe-publicip-vm01-tf"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Dynamic"

  tags = {
    "owner" = var.tag-owner
  }
}

resource "azurerm_network_interface" "nic1" {
  name                = "jclishe-nic-vm01-tf"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip1.id
  }

  tags = {
    "owner" = var.tag-owner
  }
}

resource "azurerm_linux_virtual_machine" "linux_vm1" {
  name                            = "jclishe-vm-01-tf"
  resource_group_name             = azurerm_resource_group.rg1.name
  location                        = azurerm_resource_group.rg1.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "jclishe"
  admin_password                  = "EmhT8ZUxGbpBob.DygupaW37"
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic1.id, ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    "owner" = var.tag-owner
  }
}