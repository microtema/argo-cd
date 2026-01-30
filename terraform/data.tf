data "azurerm_resource_group" "this" {
  name = local.namespace
}

data "azurerm_storage_account" "this" {
  name                = local.namespace_trimmed
  resource_group_name = data.azurerm_resource_group.this.name
}

data "azurerm_client_config" "this" {}

data "http" "ci_agent_ip" {
  url = "https://ifconfig.co/ip"
}