variable "k8s_cluster_name" {
  description = "The name of your EKS cluster"
  type        = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace to deploy Loki and Promtail"
  type        = string
  default     = "monitoring"
}

variable "loki_chart_version" {
  description = "Helm chart version for Loki"
  type        = string
  default     = "6.32.0"
}

variable "promtail_chart_version" {
  description = "Helm chart version for Promtail"
  type        = string
  default     = "6.17.0"
}

variable "loki_service_account_name" {
  description = "Service account name for Loki"
  type        = string
  default     = "loki-sa"
}

variable "promtail_service_account_name" {
  description = "Service account name for Promtail"
  type        = string
  default     = "promtail-sa"
}

 
variable "loki_storage_size" {
  description = "Size of persistent volume for Loki"
  type        = string
  default     = "10Gi"
}

variable "loki_storage_bucket" {
  description = "S3 bucket name for Loki storage (optional)"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}


variable "ebs_storage_class_name" {
  description = "EBS Storage class name for persistent volumes for Prometheus"
  type        = string
  default     = "ebs-gp3-sc"
}

variable "efs_storage_class_name" {
  description = "EFS Storage class name for persistent volumes for Prometheus"
  type        = string
  default     = "efs-sc"
}

 