terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Configure Kubernetes provider with AKS credentials
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

# Configure Helm provider with AKS credentials
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

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

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Deploy Traefik using Helm
resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "10.24.0"

  set {
    name  = "ports.web.port"
    value = "80"
  }

  set {
    name  = "ports.websecure.port"
    value = "443"
  }

  set {
    name  = "ingressRoute.dashboard.enabled"
    value = "true"
  }
  
  # Enable TCP support for VNC
  set {
    name  = "ports.vnc.port"
    value = "5900"
  }
  
  set {
    name  = "ports.vnc.exposedPort"
    value = "5900"
  }
  
  set {
    name  = "ports.vnc.expose"
    value = "true"
  }
  
  set {
    name  = "ports.vnc.protocol"
    value = "TCP"
  }
}

# Windows VM deployment
resource "kubernetes_deployment" "windows_vm" {
  count = var.windows_vm_count
  
  metadata {
    name = "windows-vm-${count.index + 1}"
    labels = {
      app = "windows-vm-${count.index + 1}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "windows-vm-${count.index + 1}"
      }
    }

    template {
      metadata {
        labels = {
          app = "windows-vm-${count.index + 1}"
        }
      }

      spec {
        container {
          image = "dockur/windows"
          name  = "windows-vm"

          port {
            container_port = 5900
            name           = "vnc"
          }
          
          port {
            container_port = 6080
            name           = "webvnc"
          }
          
          resources {
            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
            requests = {
              cpu    = "1"
              memory = "2Gi"
            }
          }
        }
      }
    }
  }
}

# Services for Windows VMs
resource "kubernetes_service" "windows_vm" {
  count = var.windows_vm_count
  
  metadata {
    name = "windows-vm-${count.index + 1}"
  }
  
  spec {
    selector = {
      app = "windows-vm-${count.index + 1}"
    }
    
    port {
      port        = 5900
      target_port = 5900
      name        = "vnc"
    }
    
    port {
      port        = 6080
      target_port = 6080
      name        = "webvnc"
    }
    
    type = "ClusterIP"
  }
}

# IngressRoute for WebVNC access
resource "kubernetes_manifest" "webvnc_ingress_route" {
  count = var.windows_vm_count
  
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "webvnc-${count.index + 1}"
      namespace = "default"
    }
    spec = {
      entryPoints = ["web"]
      routes = [
        {
          match = "Host(`vnc-${count.index + 1}.${var.base_domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "windows-vm-${count.index + 1}"
              port = 6080
            }
          ]
        }
      ]
    }
  }
}

# TCP Route for direct VNC access
resource "kubernetes_manifest" "vnc_tcp_route" {
  count = var.windows_vm_count
  
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRouteTCP"
    metadata = {
      name      = "vnc-direct-${count.index + 1}"
      namespace = "default"
    }
    spec = {
      entryPoints = ["vnc"]
      routes = [
        {
          match = "HostSNI(`*`)"
          services = [
            {
              name = "windows-vm-${count.index + 1}"
              port = 5900
            }
          ]
        }
      ]
    }
  }
}

# Outputs
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
