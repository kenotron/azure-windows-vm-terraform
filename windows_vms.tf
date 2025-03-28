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
