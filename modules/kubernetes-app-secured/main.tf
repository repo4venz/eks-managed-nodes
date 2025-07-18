 
 

 
resource "null_resource" "create_namespace_if_not_exists" {
 
  provisioner "local-exec" {
    command = <<EOT
      if ! kubectl get namespace ${var.app_namespace} >/dev/null 2>&1; then
        kubectl create namespace ${var.app_namespace}
        echo "Created namespace: ${var.app_namespace}"
      else
        echo "Namespace ${var.app_namespace} already exists"
      fi
    EOT
  }
    triggers = {
    always_run = timestamp() # Forces re-run on every `apply`; can be improved
  }
}



# Terraform module to deploy docker-2048 to EKS using NGINX Ingress

 
# -------------------
# DEPLOYMENT
# -------------------
resource "kubernetes_deployment" "this" {
  metadata {
    name      = "game-2048-secured"
    namespace = var.app_namespace
    labels = {
      app = "game-2048-secured"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "game-2048-secured"
      }
    }

    template {
      metadata {
        labels = {
          app = "game-2048-secured"
        }
      }

      spec {
        container {
          name  = "game-2048-secured"
          image = var.image

          port {
            container_port = 80
          }
        }
      }
    }
  }
   depends_on = [null_resource.create_namespace_if_not_exists]
}

# -------------------
# SERVICE
# -------------------
resource "kubernetes_service" "this" {
  metadata {
    name      = "game-2048-svc-secured"
    namespace = var.app_namespace
  }

  spec {
    selector = {
      app = "game-2048-secured"
    }

    port {
      port        = 80
      target_port = 80
    }

   # type = "NodePort"
  }
   depends_on = [null_resource.create_namespace_if_not_exists]
}

# -------------------
# INGRESS (NGINX)
# -------------------
resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = "game-2048-ingress-secured"
    namespace = var.app_namespace

    annotations = {
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-${var.environment}"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/rewrite-target"     = "/"
      "external-dns.alpha.kubernetes.io/hostname"      = var.ingress_hostname
    }
  }

  spec {
    ingress_class_name = "nginx"  #  

    tls {
      hosts       = [var.ingress_hostname]
      secret_name = "${var.app_namespace}-tls-2048-cert"
    }

    rule {
      host = var.ingress_hostname

      http {
        path {
          path      = "/"
          path_type = "Prefix"  #  

          backend {
            service {
              name = kubernetes_service.this.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [null_resource.create_namespace_if_not_exists]
}


