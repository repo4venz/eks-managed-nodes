# Install Loki using Helm
resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  namespace        = var.k8s_namespace
  version          = var.loki_chart_version
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 300

  values = [
    yamlencode({
      serviceAccount = {
        name = var.loki_service_account_name
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.loki_role.arn
        }
      }
      persistence = {
        enabled = true
        storageClassName = var.efs_storage_class_name
        size = var.loki_storage_size
      }
      loki = {
        auth_enabled = false
        commonConfig = {
          replication_factor = 1
        }
        storage = {
          type = "filesystem"
        }
      }
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.loki_policy_attachment
  ]
}
