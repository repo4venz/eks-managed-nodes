/**
output "kubecost_lb_hostname" {
  value = helm_release.kubecost.status.load_balancer.ingress.hostname
  description = "DNS name to access Kubecost UI"
}
**/

output "kubecost_url" {
  value = "https://${var.kubecost_hostname}"
   description = "DNS name to access Kubecost UI"
}