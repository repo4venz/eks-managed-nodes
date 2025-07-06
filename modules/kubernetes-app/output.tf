
data "kubernetes_ingress" "ingress_lb" {
  metadata {
    name = kubernetes_ingress_v1.game-app-ingress.id
  }
}

# Display load balancer hostname (typically present in AWS)
output "load_balancer_hostname" {
   value = data.kubernetes_ingress.ingress_lb.status.0.load_balancer.0.ingress.0.hostname
}


# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
output "load_balancer_ip" {
  value  = data.kubernetes_ingress.ingress_lb.status.0.load_balancer.0.ingress.0.ip
}


