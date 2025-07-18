 
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

  
variable "aws_test_secrets" {
  type = list(object({
    secret_name           = string
    application_namespace = string
  }))
  default = []
  description = "List of Secrets of AWS Secrets Manager and Kubernetes Application Namespace. It will map the which secrets will be accessed from which namespace"
   
}