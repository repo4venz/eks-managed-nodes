 

resource "helm_release" "k8sgpt" {
  name       = "k8sgpt"
  namespace  =  var.k8sgpt_namespace
  repository = "https://charts.k8sgpt.ai"
  chart      = "k8sgpt-operator"
  version    =  var.k8sgpt_helm_version
  create_namespace = false
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [
    yamlencode({
      serviceAccount = {
        create = false
        name   = kubernetes_service_account.k8sgpt_sa.metadata[0].name
      }
      serviceMonitor = {
          enabled   = true
          namespace = var.prometheus_namespace  # Where Prometheus is installed
          interval  = "30s"
          additionalLabels = {
            release = "kube-prometheus-stack"
          }
        }
      interplex = {
        enabled = true
      } 
    }    
  )
  ]

  depends_on = [
    aws_iam_role_policy_attachment.pod_policy_k8sgpt_attach
  ]
}

 