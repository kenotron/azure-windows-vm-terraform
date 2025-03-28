output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "vnc_web_urls" {
  value = [for i in range(var.windows_vm_count) : "http://vnc-${i + 1}.${var.base_domain}"]
  description = "URLs to access Web VNC through Traefik"
}
