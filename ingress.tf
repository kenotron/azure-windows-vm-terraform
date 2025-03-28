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
