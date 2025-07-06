variable "k8s_namespace" {
  type    = string
  default = "ingress-nginx"
}

variable "nginx_ingress_chart_version" {
  type        = string
  description = "Helm chart version for Ingress nginx LB controller"
  default     = "4.12.3"
}