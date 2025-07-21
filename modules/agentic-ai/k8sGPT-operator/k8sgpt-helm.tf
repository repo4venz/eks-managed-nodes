 

resource "helm_release" "k8sgpt" {
  name       = "k8sgpt"
  namespace  =  var.k8sgpt_namespace
  repository = "https://charts.k8sgpt.ai"
  chart      = "k8sgpt-operator"
  version    =  var.k8sgpt_helm_version
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [
    yamlencode({
      controller = {
        serviceMonitor = {
          enabled   = true
          namespace = var.prometheus_namespace  # Where Prometheus is installed
          interval  = "30s"
          additionalLabels = {
            release = "kube-prometheus-stack"
          }
        }
      }
      serviceAccount = {
        create = true
        name   = var.k8sgpt_service_account_name
      }
     
    })
  ]

  depends_on = [
    aws_eks_pod_identity_association.k8sgpt_association
  ]
}

 