variable "k8s_cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}
 
variable "k8s_namespace" {
  type    = string
  default = "monitoring"
}

variable "prometheus_chart_version" {
  type        = string
  description = "Helm chart version for kube-prometheus-stack"
  default     = "55.5.0"
}

variable grafana_ingress_hostname  {
  description = "Hostname for Grafana Ingress"
  type        = string
  default     = "grafana.example.com"
}


variable "environment" {
  description = "Environemnt of Lets Encrypt"
  type        = string
  default = "test"
}