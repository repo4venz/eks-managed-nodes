variable "k8s_cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}
 
variable "k8s_namespace" {
  type    = string
  default = "monitoring"
}

variable "prometheus_chart_version" {
  type        = string
  description = "Helm chart version for kube-prometheus-stack"
  default     = "55.5.0"
}

variable grafana_ingress_hostname  {
  description = "Hostname for Grafana Ingress"
  type        = string
  default     = "grafana.suvendupublicdomain.fun"
}


variable "environment" {
  description = "Environemnt of Lets Encrypt"
  type        = string
  default = "dev"
}


variable "prometheus_service_account_name" {
  type        = string
  description = "Service Account Name of kube-prometheus-stack"
  default     = "prometheus-sa"
}

 
variable "storage_size" {
  description = "Size of persistent volume"
  type        = string
  default     = "10Gi"
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "3d"
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

variable "prometheus_role_arn" {
  description = "IAM role arn for Prometheus"
  type        = string
  default     = ""
}