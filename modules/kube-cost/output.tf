
output "kubecost_lb_hostname" {
  value = helm_release.kubecost.status.load_balancer.ingress.hostname
  description = "DNS name to access Kubecost UI"
}
