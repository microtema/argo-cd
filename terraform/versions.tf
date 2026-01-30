terraform {
  required_version = "1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.57.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }
  }

  backend "azurerm" {
    #resource_group_name  = "mate-dev-weu-001"
    #storage_account_name = "matedevweu003"
    container_name = "tfstate"
    key            = "terraform.tfstate"
    #subscription_id = "3c9cdd92-f0c0-4bd6-8753-d0553e5545e1" # dev/test
    #subscription_id = "a69616df-7cc7-4699-9423-14eb1767430d" # preprod/prod
  }
}

provider "azurerm" {
  features {
  }
  storage_use_azuread = true
  subscription_id = var.subscription_id
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.this.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    config_path = local_file.kubeconfig.filename
  }
}