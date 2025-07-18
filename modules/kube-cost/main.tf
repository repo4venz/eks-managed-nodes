
 
 
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
      clusterName       = var.k8s_cluster_name
      awsAthenaProjectID = data.aws_caller_identity.current.account_id
      awsRegion        = data.aws_region.current.id
      metricResolution = "1m"  # Set to 1 minute for more granular metrics
      etlDailyStoreDurationDays = "365"
      etlHourlyStoreDurationHours = "720" # 30 days
    }
        
    prometheus = {
      server = {
        persistentVolume = {
          enabled      = true
          storageClass = var.storage_class
          size         = var.storage_size
          accessModes  = ["ReadWriteMany"]  #  ["ReadWriteOnce"] # for ebs use ReadWriteOnce. For efs use ReadWriteMany
        }
        retention = var.prometheus_retention
      }
      ingress = {
        enabled = true
        path    = "/"
        pathType = "Prefix"
        className = "nginx" # Ensure you have an NGINX Ingress Controller
        hosts   = [var.ingress_host]
        annotations = {
          "kubernetes.io/ingress.class"                  = "nginx"
          "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
          "cert-manager.io/cluster-issuer"               = "letsencrypt-${var.environment}"
          "external-dns.alpha.kubernetes.io/hostname"    = var.ingress_host
          "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
          "nginx.ingress.kubernetes.io/rewrite-target"     = "/"
        }
        tls     = {
          enabled = true
          secretName = "kubecost-tls" # Ensure this secret is created with the TLS certificate
        }
      }
      /*  nodeExporter = {
          enabled = true
          port    = 19100 # Custom Node Exporter port. Change to custom port if needed 
          # Use the same port for service and serviceMonitor
          service = {
            port = 19100 # Service port
            targetPort = 19100 # Container port
          }
          serviceMonitor = {
            enabled = true
            port    = "http-metrics" # Reference the port name
          }
        }

        # Kube-State-Metrics Configuration
        kubeStateMetrics = {
          enabled = true
          service = {
            port = 18080 # Custom KSM port
            targetPort = 18080 # Container port
          }
          serviceMonitor = {
            enabled = true
            port    = "http-metrics" # Reference the port name
          }
        }
      alertmanager = {
        enabled = false # Disable internal Alertmanager
      }
      operator = {
        enabled = false # Disable Prometheus Operator
      }
      serviceMonitor = {
        enabled = true
        interval = "30s"
        scrapeTimeout = "10s"
      }
      service = {
        enabled = true
        type    = "ClusterIP"
      }
      pushgateway = {
        enabled = false # Disable Pushgateway
      }*/
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



/*
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
    helm_release.kubecost 
  ]
}

*/

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