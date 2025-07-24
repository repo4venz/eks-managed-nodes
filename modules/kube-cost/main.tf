
 
 
# Kubecost Helm Release (Use it's own Prometheus and Graphana Servers)
resource "helm_release" "kubecost" {
  name       = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  version    = var.kubecost_chart_version
  namespace  = var.namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900
  
    # Use a values file instead of inline values
  values = [
    templatefile("${path.module}/kubecost-values.yaml", {
      k8s_cluster_name = var.k8s_cluster_name
      service_account_name = var.service_account_name
      kubecost_iam_role_arn = aws_iam_role.kubecost.arn
      aws_account_id = data.aws_caller_identity.current.account_id
      storage_class = var.storage_class
      storage_size = var.storage_size
      ingress_host  = var.ingress_host
      environment = var.environment
      prometheus_namespace  = var.prometheus_namespace
      aws_region = data.aws_region.current.id
    })
  ]

  /*
values = [
  yamlencode({
    global = {
      clusterName = var.k8s_cluster_name
    }

    serviceAccount = {
      create = true
      name   = var.service_account_name
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.kubecost.arn
      }
    }

    kubecostProductConfigs = {
      clusterName            = var.k8s_cluster_name
      awsAthenaProjectID     = data.aws_caller_identity.current.account_id
      awsRegion              = data.aws_region.current.id
      metricResolution       = "1m"
      etlDailyStoreDurationDays  = "30"
      etlHourlyStoreDurationHours = "720"

      prometheus = {
        server = {
          persistentVolume = {
            enabled      = true
            size         = var.storage_size
            storageClass = var.storage_class
            accessModes  = ["ReadWriteMany"]
          }
        }
      }

      service = {
        type = "ClusterIP"
      }

      resources = {
        requests = {
          cpu    = "200m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "1000m"
          memory = "2Gi"
        }
      }

      networkCosts = {
        enabled = true
      }

      serviceMonitor = {
        enabled = true
        additionalLabels = {
          release = "kube-prometheus"  # must match kube-prometheus label
        }
        interval = "30s"
      }
    }
  })
]

*/

 
  depends_on = [
    aws_iam_role_policy_attachment.kubecost,
    aws_iam_role_policy_attachment.kubecost_custom
    ]
}


/*
resource "time_sleep" "wait_120_seconds" {
  create_duration = "120s"  # 2 minutes

  depends_on = [
    # Resources that must complete before waiting
    helm_release.kubecost 
  ]
}
 
# Ingress with TLS
resource "kubernetes_ingress_v1" "kubecost" {
  metadata {
    name        = "kubecost-ingress"
    namespace   = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                  = "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "cert-manager.io/cluster-issuer"               = "letsencrypt-${var.environment}"
      "external-dns.alpha.kubernetes.io/hostname"    = var.ingress_host
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/rewrite-target"     = "/"
    }
  }

  spec {
    rule {
      host = var.ingress_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kubecost-cost-analyzer"
              port {
                number = 9090
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = [var.ingress_host]
      secret_name = "kubecost-tls"
    }
  }

  depends_on = [
    helm_release.kubecost,
    time_sleep.wait_120_seconds
  ]
}
*/