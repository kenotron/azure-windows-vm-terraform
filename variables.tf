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

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
  default     = "fill-this-out-in-main.tf" # Update with your domain
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "AI-k8s-Ken"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "southcentralus"
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "ken-k8s"
}

variable "cluster_dns_prefix" {
  description = "AKS cluster dns prefix name"
  type        = string
  default     = "ken-k8s-dns"
}