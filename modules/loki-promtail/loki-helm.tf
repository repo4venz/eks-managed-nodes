 
# Helm Release for Loki with yamlencoded values
# Loki will be installed using Helm with the specified configuration.
# Loki is a log aggregation system designed to work with Prometheus.
# Loki stores logs in a time-series database and allows querying logs using PromQL-like queries.
#Loki stores logs in S3, and the configuration includes storage settings, schema, and service account details.
 
 
 
resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  version          = var.loki_chart_version
  namespace        = var.k8s_namespace
  create_namespace = true
  atomic           = true  # Set to false to debug installation issues
  cleanup_on_fail  = true
  timeout          = 300

  # Use a values file instead of inline values
  values = [
    templatefile("${path.module}/loki-values.yaml", {
      loki_service_account_name = var.loki_service_account_name
      loki_role_arn = aws_iam_role.loki_role.arn
      s3_bucket_name = aws_s3_bucket.loki_storage.id
      aws_region = data.aws_region.current.id
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.loki_policy_attachment,
    aws_s3_bucket.loki_storage
  ]
}

 
  