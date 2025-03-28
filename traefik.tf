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
