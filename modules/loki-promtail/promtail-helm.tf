
# Install Promtail using Helm
resource "helm_release" "promtail" {
  name             = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  namespace        = var.k8s_namespace
  version          = var.promtail_chart_version
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 300

  values = [
    yamlencode({
      serviceAccount = {
        name = var.promtail_service_account_name
      }
      config = {
        clients = [
          {
            url = "http://loki:3100/loki/api/v1/push"
          }
        ]
      }
    })
  ]

  depends_on = [
    helm_release.loki
  ]
}