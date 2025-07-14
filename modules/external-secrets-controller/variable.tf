
# modules/kubecost/variables.tf
variable "k8s_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy External Secrets"
  type        = string
  default     = "external-secrets"
}

variable "service_account_name" {
  description = "Name of the External Secrets service account"
  type        = string
  default     = "external-secrets-sa"
}
 
variable "external_secret_chart_version" {
  description = "External Secrets Helm chart version"
  type        = string
  default     = "0.18.2"
}


variable "aws_test_secrets" {
  type = list(object({
    secret_name           = string
    application_namespace = string
    k8s_secret_store_name = string
  }))
  default = []
  description = "List of Secrets of AWS Secrets Manager and Kubernetes Application Namespace. It will map the which secrets will be accessed from which namespace"
   
}

 