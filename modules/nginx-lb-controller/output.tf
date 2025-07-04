
output "nginx_ingress_controller_service" {
  value = helm_release.nginx_ingress.status
}