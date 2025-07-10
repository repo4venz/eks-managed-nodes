
# modules/kubecost/variables.tf
variable "k8s_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy External Secret"
  type        = string
  default     = "external-secrets"
}

variable "service_account_name" {
  description = "Name of the External Secret service account"
  type        = string
  default     = "external-secret-sa"
}
 
variable "external_secret_chart_version" {
  description = "External Secret Helm chart version"
  type        = string
  default     = "0.18.2"
}

 