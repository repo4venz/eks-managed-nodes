
/*
resource "kubernetes_namespace" "application_namespace" {
  count = var.create_namespace ? 1 : 0
  metadata {
    labels = {
      "app.kubernetes.io/name" = "sample-game-app"
    }
    name = var.app_namespace
  }
}
*/

 

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

resource "kubernetes_deployment" "game-app" {
  metadata {
    name      = "game-app"
    namespace =  var.app_namespace #kubernetes_namespace.application_namespace.metadata.0.name
    labels    = {
      "app.kubernetes.io/name" = "sample-game-app"
    }
  }
  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "sample-game-app"
      }
    }
    replicas = 3

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "sample-game-app"
        }
      }

      spec {
        container {
          image = "public.ecr.aws/l6m2t8p7/docker-2048:latest"
          name  = "sample-game-app"
          image_pull_policy = "Always"
          port {
            container_port = 80
          }
        }
      }
    }
  }
   depends_on = [null_resource.create_namespace_if_not_exists]
}

resource "kubernetes_service_v1" "game-app-service" {
  metadata {
    name      = "game-app-service"
    namespace = var.app_namespace # kubernetes_namespace.application_namespace.metadata.0.name
  }
  spec {
    selector = {
        "app.kubernetes.io/name" = "sample-game-app"
    }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "NodePort"
  }
  depends_on = [kubernetes_deployment.game-app]
}



resource "kubernetes_ingress_v1" "game-app-ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "game-app-ingress"
    namespace = var.app_namespace #kubernetes_namespace.application_namespace.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class"           = "nginx"  #"alb"
      "nginx.ingress.kubernetes.io/rewrite-target"      = "/"
      "nginx.ingress.kubernetes.io/ssl-redirect"        = "false"
      "external-dns.alpha.kubernetes.io/hostname" = "sample-app.suvendu.public-dns.aws"
    }
  }
  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service_v1.game-app-service.metadata.0.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_service_v1.game-app-service
  ]
}
