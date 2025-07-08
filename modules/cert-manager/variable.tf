variable "k8s_cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}


variable "namespace" {
  type        = string
  default = "cert-manager"
}

variable "install_crds" {
  type    = bool
  default = true
}

variable "certmanager_chart_version" {
  default = "1.18.2"
  description = "Version of cert-manager Helm chart to install"
}
