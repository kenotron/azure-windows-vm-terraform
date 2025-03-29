import {
  id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  to = azurerm_resource_group.rg
}

import {
  id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ContainerService/managedClusters/${var.cluster_name}"
  to = azurerm_kubernetes_cluster.aks
}
