
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

variable "email" {
  description = "Email address for Let's Encrypt notifications"
  type        = string
  default     = "suvendu.mandal@gmail.com"
}

variable "enable_lets_encrypt_ca" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}


variable "k8s_cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}


variable "route53_zone_id" {
  description = "The ID of the Route53 hosted zone"
  type        = string
  default = "Z00719261GUBMEJWEC48W"
}
    