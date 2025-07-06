

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  namespace  = var.k8s_namespace
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.nginx_ingress_chart_version  # Check for latest compatible version if needed
  atomic           = true
  cleanup_on_fail = true
  timeout    = 900

values = [
  yamlencode({
    controller = {
      service = {
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-type" = "elb"   #"nlb" # or elb
        }
        targetPorts = {
          http  = "http"
          https = "https"
        }
      }
    }
  })
]
}