# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "eastus2"
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_dns_prefix

  automatic_upgrade_channel = "patch"
  image_cleaner_enabled = true
  image_cleaner_interval_hours = 168
  oidc_issuer_enabled = true
  workload_identity_enabled = true

  default_node_pool {
    name       = "nodepool"
    node_count = 2
    vm_size    = "Standard_D2as_v5"

    auto_scaling_enabled = true
    max_count = 5
    min_count = 2
    node_public_ip_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }
}
