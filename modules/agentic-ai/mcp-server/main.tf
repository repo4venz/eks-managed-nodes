
 
## Deploy MCP Server using Helm
resource "helm_release" "mcp_server" {
  name       = "mcp-server"
  namespace  = var.namespace
  repository = var.helm_repo_url
  chart      = "mcp-server"
  #version    = var.mcp_server_chart_version
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = var.service_account_name
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.pod_identity_role_mcp_server.arn
        }
      }
      image = {
        repository = var.mcp_image_repo
        tag        = var.mcp_image_tag
      }
      service = {
        port = var.mcp_port
      }
      replicaCount = var.mcp_replicas
      resources = {
        requests = {
          cpu    = var.mcp_cpu_request
          memory = var.mcp_memory_request
        }
        limits = {
          cpu    = var.mcp_cpu_limit
          memory = var.mcp_memory_limit
        }
      }
      config = {
        server = {
          port = var.mcp_port
        }
        logging = {
          level = "info"
        }
      }
      ingress = {
        enabled = true
        hosts = [
          {
            host = "${var.ingress_host}"
            paths = "/"
            pathType = "Prefix"
          }
        ]
        annotations = {
            "kubernetes.io/ingress.class" = "nginx"
            "nginx.ingress.kubernetes.io/rewrite-target" = "/"
            "cert-manager.io/cluster-issuer"               = "letsencrypt-${var.environment}"
            "external-dns.alpha.kubernetes.io/hostname"    = var.ingress_host
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/rewrite-target"     = "/"          
        }
        tls = [
          {
            secretName = "mcp-server-tls"
            hosts      = [var.ingress_host] 
          }
        ]
      }
    })
  ]
}

