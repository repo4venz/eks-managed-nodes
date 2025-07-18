
 
## Create Namespace for MCP Server
resource "kubernetes_namespace_v1" "mcp_namespace" {
  metadata {
    name = var.namespace
  }
}

## Create Service Account for MCP Server
resource "kubernetes_service_account_v1" "mcp_service_account" {
  metadata {
    name      = var.service_account_name
    namespace = kubernetes_namespace_v1.mcp_namespace.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.pod_identity_role_mcp_server.arn
    }
  }
}

## Create ConfigMap for MCP Server
resource "kubernetes_config_map_v1" "mcp_config" {
  metadata {
    name      = "mcp-server-config"
    namespace = kubernetes_namespace_v1.mcp_namespace.metadata[0].name
  }

  data = {
    "config.yaml" = jsonencode({
      server = {
        port = var.mcp_port
      }
      logging = {
        level = "info"
      }
    })
  }
}

## Create Deployment for MCP Server
resource "kubernetes_deployment_v1" "mcp_server" {
  metadata {
    name      = "mcp-server"
    namespace = kubernetes_namespace_v1.mcp_namespace.metadata[0].name
  }

  spec {
    replicas = var.mcp_replicas

    selector {
      match_labels = {
        app = "mcp-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "mcp-server"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.mcp_service_account.metadata[0].name
        
        container {
          name  = "mcp-server"
          image = "${var.mcp_image_repo}:${var.mcp_image_tag}"
          
          port {
            container_port = var.mcp_port
          }
          
          resources {
            requests = {
              cpu    = var.mcp_cpu_request
              memory = var.mcp_memory_request
            }
            limits = {
              cpu    = var.mcp_cpu_limit
              memory = var.mcp_memory_limit
            }
          }
          
          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/mcp"
          }
          
          env {
            name  = "MCP_CONFIG_PATH"
            value = "/etc/mcp/config.yaml"
          }
        }
        
        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map_v1.mcp_config.metadata[0].name
          }
        }
      }
    }
  }
}

## Create Service for MCP Server
resource "kubernetes_service_v1" "mcp_service" {
  metadata {
    name      = "mcp-server"
    namespace = kubernetes_namespace_v1.mcp_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "mcp-server"
    }
    
    port {
      port        = var.mcp_port
      target_port = var.mcp_port
      protocol    = "TCP"
    }
    
    type = "ClusterIP"
  }
}

## Create Ingress for MCP Server
resource "kubernetes_ingress_v1" "mcp_ingress" {
  metadata {
    name      = "mcp-server-ingress"
    namespace = kubernetes_namespace_v1.mcp_namespace.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "cert-manager.io/cluster-issuer" = "letsencrypt-${var.environment}"
      "external-dns.alpha.kubernetes.io/hostname" = var.ingress_host
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "external-dns.alpha.kubernetes.io/hostname"    = var.ingress_host
    }
  }

  spec {
    tls {
      hosts       = [var.ingress_host]
      secret_name = "mcp-server-tls"
    }
    
    rule {
      host = var.ingress_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.mcp_service.metadata[0].name
              port {
                number = var.mcp_port
              }
            }
          }
        }
      }
    }
  }
}

