
 
 
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
  
values = [
  yamlencode({
    global = { clusterName = var.k8s_cluster_name }
    
    serviceAccount = {
      create = true
      name = var.service_account_name
      annotations = { "eks.amazonaws.com/role-arn" = aws_iam_role.kubecost.arn }
    }

    kubecostProductConfigs = {
      clusterName = var.k8s_cluster_name
      awsAthenaProjectID = data.aws_caller_identity.current.account_id
      awsRegion = data.aws_region.current.id
      
      # Storage settings
      metricResolution = "1m"
      etlDailyStoreDurationDays = "30"
      etlHourlyStoreDurationHours = "720"
      
      # Prometheus config
      prometheus = {
        server = {
          persistentVolume = {
            enabled = true
            size = var.storage_size
            storageClass = var.storage_class
            accessModes = ["ReadWriteMany"]  #["ReadWriteOnce"]  # for EBS use ReadWriteOnce and for EFS use ReadWriteMany
          }
        }
      }   
      # Service and resources
      service = { type = "ClusterIP" }
      resources = {
        requests = { cpu = "200m", memory = "512Mi" }
        limits = { cpu = "1000m", memory = "2Gi" }
      }
      
      # Features
      networkCosts = { enabled = true }
      serviceMonitor = { enabled = true, namespace = var.prometheus_namespace }
    }
  })
  
  #,file("${path.module}/kubecost-advanced-values.yaml")
]
  depends_on = [
    aws_iam_role_policy_attachment.kubecost,
    aws_iam_role_policy_attachment.kubecost_custom
    ]
}
 


/*# Kubecost Helm Release ( Use existing Prometheus but own kube-cost bunddled Graphana Server)

#http://prometheus-operated.monitoring.svc.cluster.local:9090 (Existing Prometheus Service)

# Kubecost Helm Release ( Use existing Prometheus but own kube-cost bunddled Graphana Server)
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
  
values = [
  yamlencode({
    global = {
      clusterName = var.k8s_cluster_name
      prometheus  = {
        url = "http://prometheus-operated.${var.prometheus_namespace}.svc.cluster.local:9090" # Use existing Prometheus Service
        enabled = false
      }
    }
    
    serviceAccount = {
      create = true
      name   = var.service_account_name
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.kubecost.arn
      }
    }
    
    kubecostProductConfigs = {
      clusterName       = var.k8s_cluster_name
      awsAthenaProjectID = data.aws_caller_identity.current.account_id
      awsRegion        = data.aws_region.current.id
    }
    
    prometheus = {
      enabled = false # Disable internal Prometheus  # Disable Kubecost's bundled Prometheus
      # Use existing Prometheus Service
      fqdn = "http://prometheus-operated.${var.prometheus_namespace}.svc.cluster.local"
      service = {
        port = 9090
      }
      operator = {
        enabled = false # Disable Prometheus Operator
      }  
    }
  })
]
  depends_on = [
    aws_iam_role_policy_attachment.kubecost,
    aws_iam_role_policy_attachment.kubecost_custom
    ]
}
*/


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

 

/*

### This is for Vertical Pod Autoscaler (VPA) for Kubecost
# Vertical Pod Autoscaler (VPA) for Kubecost
# This is an example configuration for VPA, adjust resource limits as needed
# Only for testing purpose, not recommended for production
resource "kubernetes_vertical_pod_autoscaler" "kubecost_vpa" {
  metadata {
    name = "kubecost-vpa"
    namespace = "kubecost"
  }
  spec {
    target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "kubecost-cost-analyzer"
    }
    update_policy {
      update_mode = "Auto"
    }
    resource_policy {
      container_policies {
        container_name = "cost-analyzer"
        min_allowed = {
          cpu = "200m"
          memory = "512Mi"
        }
        max_allowed = {
          cpu = "2"
          memory = "8Gi"
        }
      }
    }
  }
}

*/