variable "k8s_cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}
 
variable "k8s_namespace" {
  type    = string
  default = "kube-system"
}


variable "kubecost_chart_version" {
  type        = string
  description = "Helm chart version for kube-cost"
  default     = "2.8.0"
}
