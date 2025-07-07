
variable "namespace" {
  default = "cert-manager"
}

variable "install_crds" {
  type    = bool
  default = true
}

variable "certmanager_chart_version" {
  default = "1.14.4"
  description = "Version of cert-manager Helm chart to install"
}