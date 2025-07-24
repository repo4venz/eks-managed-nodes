
# Install Promtail using Helm


resource "helm_release" "promtail" {
  name             = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  version          = var.promtail_chart_version
  namespace        = var.k8s_namespace
  create_namespace = true
  atomic           = false  # Set to false to debug installation issues
  cleanup_on_fail  = true
  timeout          = 300

  # Use a values file instead of inline values
  values = [
    templatefile("${path.module}/promtail-values.yaml", {
      promtail_service_account_name = var.promtail_service_account_name
    })
  ]

  depends_on = [
    helm_release.loki
  ]
}

 
/*

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
    serviceMonitor = {
        enabled = true
        additionalLabels = {
          release = "kube-prometheus-stack"
        }   
        }
      config = {
        clients = [{
          url = "http://loki.${var.k8s_namespace}.svc.cluster.local:3100/loki/api/v1/push"
        }]
        snippets = {
          pipelineStages = [
            { cri = {} }
          ]
          scrape_configs = [{
            job_name = "kubernetes-pods"
            kubernetes_sd_configs = [{
              role = "pod"
            }]
            relabel_configs = [
              {
                source_labels = ["__meta_kubernetes_namespace"]
                target_label  = "namespace"
              },
              {
                source_labels = ["__meta_kubernetes_pod_name"]
                target_label  = "pod"
              },
              {
                source_labels = ["__meta_kubernetes_pod_container_name"]
                target_label  = "container"
              }
            ]
          }]
        }
      }
    })
  ]

  depends_on = [
    helm_release.loki
  ]
}
*/
