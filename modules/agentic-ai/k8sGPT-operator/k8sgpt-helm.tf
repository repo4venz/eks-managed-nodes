 

resource "helm_release" "k8sgpt" {
  name       = "k8sgpt"
  namespace  =  var.k8sgpt_namespace
  repository = "https://charts.k8sgpt.ai"
  chart      = "k8sgpt-operator"
  version    =  var.k8sgpt_device_plugin_version
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [
    yamlencode({
      controller = {
        serviceMonitor = {
          enabled   = true
          namespace = "monitoring"  # Where Prometheus is installed
          interval  = "30s"
          additionalLabels = {
            release = "kube-prometheus-stack"
          }
        }
      }
      serviceAccount = {
        create = true
        name   = "${var.k8sgpt_service_account_name}"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_eks_pod_identity_association.k8sgpt_association.arn
        }
      }
      ingress = {
        enabled = true
        annotations = {
            "kubernetes.io/ingress.class"                  = "nginx"
            "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
            "cert-manager.io/cluster-issuer"               = "letsencrypt-${var.environment}"
            "external-dns.alpha.kubernetes.io/hostname"    = var.ingress_host
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/rewrite-target"     = "/"
        }
        hosts = [{
          host  = var.ingress_host
          paths = [{
            path     = "/"
            pathType = "Prefix"
          }]
        }]
        tls = [{
          secretName = "k8sgpt-tls"
          hosts      = [var.ingress_host]
        }]
      }
    })
  ]

  depends_on = [
    aws_eks_pod_identity_association.k8sgpt_device_plugin_association
  ]
}

 