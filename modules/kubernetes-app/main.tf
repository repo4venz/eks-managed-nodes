 
resource "null_resource" "create_namespace_if_not_exists" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl get namespace ${var.app_namespace} || kubectl create namespace ${var.app_namespace}
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
    name      = "game-2048"
    namespace = var.app_namespace
    labels = {
      app = "game-2048"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "game-2048"
      }
    }

    template {
      metadata {
        labels = {
          app = "game-2048"
        }
      }

      spec {
        container {
          name  = "game-2048"
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
    name      = "game-2048-svc"
    namespace = var.app_namespace
  }

  spec {
    selector = {
      app = "game-2048"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
   depends_on = [null_resource.create_namespace_if_not_exists]
}

# -------------------
# INGRESS (NGINX)
# -------------------
resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = "game-2048-ingress"
    namespace = var.app_namespace
    annotations = {
      "kubernetes.io/ingress.class" : "nginx"
      "external-dns.alpha.kubernetes.io/hostname" = "game-notsecured.suvendupublicdomain.fun"
    }
  }

  spec {
    rule {
      http {
        path {
          path     = "/"
          path_type = "Prefix"

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


 