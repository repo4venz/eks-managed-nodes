
data "kubernetes_ingress" "ingress_lb" {
  metadata {
    name = kubernetes_ingress_v1.game-app-ingress.metadata[0].name
  }
}

output "ingress_name" {
  value = kubernetes_ingress_v1.game-app-ingress.metadata[0].name
}

# Display load balancer hostname (typically present in AWS)
output "load_balancer_hostname" {
   value = data.kubernetes_ingress.ingress_lb.status.load_balancer.ingress.hostname
}


# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
output "load_balancer_ip" {
  value  = data.kubernetes_ingress.ingress_lb.status.load_balancer.ingress.ip
}


