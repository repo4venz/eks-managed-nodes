variable "k8s_cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}
 


variable "k8s_namespace" {
  type    = string
  default = "kube-system"
}