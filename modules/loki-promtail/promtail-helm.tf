
# Install Promtail using Helm


resource "helm_release" "promtail" {
  name             = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  version          = var.promtail_chart_version
  namespace        = var.k8s_namespace
  create_namespace = true
  atomic           = true  # Set to false to debug installation issues
  cleanup_on_fail  = true
  timeout          = 300

  # Use a values file instead of inline values
  values = [
    templatefile("${path.module}/promtail-values.yaml", {
      promtail_service_account_name = var.promtail_service_account_name
      prometheus_namespace = var.prometheus_namespace
    })
  ]

  depends_on = [
    helm_release.loki
  ]
}

  