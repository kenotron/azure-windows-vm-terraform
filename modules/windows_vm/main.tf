# Windows VM module
resource "kubernetes_deployment" "windows_vm" {
  metadata {
    name = "windows-vm-${var.vm_index}"
    labels = {
      app = "windows-vm-${var.vm_index}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "windows-vm-${var.vm_index}"
      }
    }

    template {
      metadata {
        labels = {
          app = "windows-vm-${var.vm_index}"
        }
      }

      spec {
        container {
          image = var.image
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
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
          }
        }
      }
    }
  }
}

# Service for Windows VM
resource "kubernetes_service" "windows_vm" {
  metadata {
    name = "windows-vm-${var.vm_index}"
  }
  
  spec {
    selector = {
      app = "windows-vm-${var.vm_index}"
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
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "webvnc-${var.vm_index}"
      namespace = "default"
    }
    spec = {
      entryPoints = ["web"]
      routes = [
        {
          match = "Host(`vnc-${var.vm_index}.${var.base_domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "windows-vm-${var.vm_index}"
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
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRouteTCP"
    metadata = {
      name      = "vnc-direct-${var.vm_index}"
      namespace = "default"
    }
    spec = {
      entryPoints = ["vnc"]
      routes = [
        {
          match = "HostSNI(`*`)"
          services = [
            {
              name = "windows-vm-${var.vm_index}"
              port = 5900
            }
          ]
        }
      ]
    }
  }
}
