variable "k8s_namespace" {
  type    = string
  default = "kube-system"
}

variable "k8s_cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "metrics_server_chart_version" {
  type        = string
  description = "Helm chart version for K8s Metrics Server"
  default     = "3.12.1"
}