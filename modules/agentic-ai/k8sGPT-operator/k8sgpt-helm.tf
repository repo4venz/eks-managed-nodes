 

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
        name   = var.k8sgpt_service_account_name
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.k8sgpt_irsa_role.arn
        }   
      }
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
      prometheus = {
        enabled = true
        namespace = var.prometheus_namespace  # Where Prometheus is installed
      }
      grafana = {
        enabled = true
        namespace = var.prometheus_namespace  # Where Grafana is installed
      }
      interplex = {
        enabled = true
      } 
    }    
  )
  ]

  depends_on = [
    aws_iam_role_policy_attachment.k8sgpt_policy_attach
  ]
}

 