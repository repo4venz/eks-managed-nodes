variable "k8s_cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}
 
variable "k8s_namespace" {
  type    = string
  default = "kube-system"
}

variable "external_dns_chart_version" {
  description = "Version of the External DNS Helm chart"
  type        = string
  default     = "1.17.0" # Update this to the desired version
}