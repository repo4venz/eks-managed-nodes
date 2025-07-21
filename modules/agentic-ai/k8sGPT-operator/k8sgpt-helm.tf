 

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
      serviceAccount = {
        create = true
        name = "k8sgpt-operator-sa" #var.k8sgpt_service_account_name
        annotations = { "eks.amazonaws.com/role-arn" = aws_iam_role.pod_identity_role_k8sgpt.arn }
      }
      serviceMonitor = {
          enabled   = false
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

 