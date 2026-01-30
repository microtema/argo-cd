# Azure virtual network space for quickstart resources
resource "azurerm_virtual_network" "this" {
  name                = local.namespace
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  address_space = var.vnet_address_space

  tags = local.tags
}

# Azure internal subnet for quickstart resources
resource "azurerm_subnet" "this" {
  name                = local.namespace
  resource_group_name = data.azurerm_resource_group.this.name

  address_prefixes = var.subnet_main_address_prefixes

  virtual_network_name = azurerm_virtual_network.this.name
}

resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "ssh_private_key_pem" {
  filename        = "${path.module}/.ssh/id_rsa"
  content         = tls_private_key.global_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "ssh_public_key_openssh" {
  filename = "${path.module}/.ssh/id_rsa.pub"
  content  = tls_private_key.global_key.public_key_openssh
}

# Public IP of Rancher server
resource "azurerm_public_ip" "this" {
  name                = local.namespace
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  allocation_method = "Static"
  sku               = "Standard"
  sku_tier          = "Regional"

  ddos_protection_mode = "Disabled"

  tags = local.tags
}

resource "azurerm_network_security_group" "this" {
  name                = local.namespace
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  tags = local.tags
}

# Allow SSH from a single source IP
resource "azurerm_network_security_rule" "allow_ssh_from_agent_ip" {
  name                        = "Allow-SSH-From-Agent-IP"
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this.name

  priority  = 1000
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22" # ssh port

  source_address_prefixes    = ["${local.agent_ip}/32"]
  destination_address_prefix = "*"
}
