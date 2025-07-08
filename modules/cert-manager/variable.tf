
variable "namespace" {
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

    