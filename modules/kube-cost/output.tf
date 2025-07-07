
output "kubecost_lb_hostname" {
  value = helm_release.kubecost.status[0].load_balancer[0].ingress[0].hostname
  description = "DNS name to access Kubecost UI"
}
