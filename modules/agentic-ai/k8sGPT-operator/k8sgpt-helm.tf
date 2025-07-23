 
 
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
  wait = true

  values = [
    yamlencode({
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.pod_identity_role_k8sgpt.arn
        }   
      }
      serviceMonitor = {
        enabled   = true
        namespace = var.prometheus_namespace  # Where Prometheus is installed
        interval  = "30s"
        additionalLabels = {
            release = "kube-prometheus"  # Adjust this label based on your Prometheus setup
        }
      }
    resources = {
      limits = {
        cpu = "500m"
        memory = "512Mi"
      }
       requests = {
         cpu = "250m"
         memory = "256Mi"
      }
    }
      prometheus = {
        enabled = true
        namespace = var.prometheus_namespace  # Where Prometheus is installed
      }
      prometheusOperator = {
        enabled = true
        namespace = var.prometheus_namespace  # Where Prometheus Operator is installed
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
    aws_iam_role_policy_attachment.pod_policy_k8sgpt_attach
  ]
}

 
 