variable "k8s_cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}
 
variable "k8s_namespace" {
  type    = string
  default = "kube-system"
}

variable "fluentbit_chart_version" {
  type        = string
  description = "Helm chart version for kube-fluentbit-stack"
  default     = "0.50.0"
}