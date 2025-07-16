variable "k8s_cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}
 variable "environment" {}
 
 variable cluster_name {}
 
variable "app_namespace" {
  description = "Business Application Namespaces"
  type        = list(string)
  default     = ["myapps1", "myapps2"]
}

variable "cluster_version" {}

variable "region_name" {
  description = "AWS Region code"
  default = "eu-west-2"
}
 
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags e.g. `map('BusinessUnit`,`XYZ`)"
}


variable "application-external-secrets_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}


variable "include_k8s_app_secured_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}

 
 variable "include_k8s_app_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}


variable "public_domain_name" {
  description = "Public Domain name hosted in Route53. e.g. suvendupublicdomain.fun"
  type        = string
  default = ""
}

 