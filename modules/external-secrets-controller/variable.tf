
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



 