

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = var.k8s_namespace
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.12.3" # Check for latest compatible version if needed
  atomic           = true
  cleanup_on_fail = true

  values = [
    yamlencode({
      controller = {
        service = {
          type = "LoadBalancer"
        }
      }
    })
  ]
}