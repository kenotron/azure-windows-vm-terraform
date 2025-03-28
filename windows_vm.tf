# Windows VM deployments using module
module "windows_vm" {
  source = "./modules/windows_vm"
  
  count = var.windows_vm_count
  
  vm_index    = count.index + 1
  base_domain = var.base_domain
  
  # Optional - uncomment to override defaults
  # image          = "dockur/windows"
  # cpu_limit      = "2"
  # memory_limit   = "4Gi"
  # cpu_request    = "1"
  # memory_request = "2Gi"
}
