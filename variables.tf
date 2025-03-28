variable "windows_vm_count" {
  description = "Number of Windows VM containers to create"
  type        = number
  default     = 3
}

variable "base_domain" {
  description = "Base domain for Traefik routing"
  type        = string
  default     = "azure-example.com" # Update with your domain
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "windows-vnc-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "windows-vnc-aks"
}
