
#This runs on every GPU node and exports GPU metrics to Prometheus.
#NVIDIA DCGM Exporter — collects GPU metrics and exposes them as Prometheus metrics.

resource "helm_release" "nvidia_dcgm_exporter" {
  name       = "nvidia-dcgm-exporter"
  repository = "https://nvidia.github.io/dcgm-exporter/helm-charts"
  chart      = "dcgm-exporter"
  #version    = var.nvidia_dcgm_exporter_helm_version
  namespace  = var.nvidia_plugin_namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900
  wait = true

  values = [
    yamlencode({
      resources = {
        limits = {
          "nvidia.com/gpu" = 1
        }
      }
      podAnnotations = {
        "prometheus.io/scrape" = "true"
        "prometheus.io/port"   = "9400"
      }
      serviceMonitor = {
        enabled   = true
        namespace = var.prometheus_namespace
        interval  = "30s"
      }
      nodeSelector = {
        "nvidia.com/gpu.present" = "true"
      }
      tolerations = [
        {
          key      = "nvidia.com/gpu"
          operator = "Exists"
          effect   = "NO_SCHEDULE"
        } 
      ]
    })
  ]

  depends_on = [
    helm_release.nvidia_device_plugin
  ]
}


resource "grafana_dashboard" "nvidia_gpu" {
  config_json = file("${path.module}/NVIDIA-DCGM-Exporter-Dashboard.json")
  folder      = "GPU"
  depends_on  = [helm_release.nvidia_dcgm_exporter]
}
