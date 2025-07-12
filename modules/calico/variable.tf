variable "k8s_cluster_name" {
  description = "EKS cluster name"
  type        = string
}


variable "calico_chart_version" {
  description = "Calico Helm Chart version"
  type        = string
  default     = "3.30.2"
}

variable "namespace" {
  description = "Namespace to deploy Calico"
  type        = string
  default     = "tigera-operator"
}