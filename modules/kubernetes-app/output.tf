
/** data "kubernetes_ingress" "ingress_lb" {
  metadata {
    name = kubernetes_ingress_v1.game-app-ingress.metadata[0].name
  }
}

output "ingress_name" {
  value = kubernetes_ingress_v1.game-app-ingress.metadata[0].name
}

# Display load balancer hostname (typically present in AWS)
output "load_balancer_hostname" {
   value = kubernetes_ingress_v1.game-app-ingress.status[0].load_balancer[0].ingress[0].hostname
}


# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
output "load_balancer_ip" {
   value = kubernetes_ingress_v1.game-app-ingress.status[0].load_balancer[0].ingress[0].ip
}
*/


# -------------------
# OUTPUT
# -------------------
output "ingress_hostname" {
  value = var.ingress_hostname
  description = "DNS host to access the game UI."
}

