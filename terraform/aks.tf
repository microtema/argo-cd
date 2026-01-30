resource "azurerm_kubernetes_cluster" "this" {
  name                = local.namespace
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  dns_prefix          = local.namespace

  kubernetes_version = "1.34.1"

  node_resource_group = replace(local.namespace_placeholder, "{placeholder}", "aks")

  api_server_access_profile {
    authorized_ip_ranges = [local.agent_ip]
  }

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_D2s_v5"
    vnet_subnet_id = azurerm_subnet.this.id
    os_sku         = "AzureLinux"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    outbound_type  = "loadBalancer"
    service_cidr   = "10.240.0.0/16"
    dns_service_ip = "10.240.0.10"
  }

  # For demos: enable RBAC
  role_based_access_control_enabled = true

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "local_file" "kubeconfig" {
  content  = azurerm_kubernetes_cluster.this.kube_config_raw
  filename = "${path.module}/.aks/${var.environment}/kubeconfig.yaml"
}