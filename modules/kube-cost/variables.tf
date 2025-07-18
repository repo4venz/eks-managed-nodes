 

variable "environment" {
  description = "Environemnt of Kube-Cost"
  type        = string
  default = "dev"
}

variable "kubecost_iam_policies" {
  description = "List of IAM policy ARNs to attach to the Kubecost IAM role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSResourceGroupsReadOnlyAccess"
  ]
}


# modules/kubecost/variables.tf
variable "k8s_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy Kubecost"
  type        = string
  default     = "kubecost"
}

variable "service_account_name" {
  description = "Name of the Kubecost service account"
  type        = string
  default     = "kubecost-sa"
}
 
variable "kubecost_chart_version" {
  description = "Kubecost Helm chart version"
  type        = string
  default     = "2.8.0"
}

variable "storage_class" {
  description = "Storage class for persistent volume"
  type        = string
  default     = "efs-sc"      #"ebs-gp3-sc"  # Use gp3 for better performance
}

variable "storage_size" {
  description = "Size of persistent volume"
  type        = string
  default     = "2Gi"
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "3d"
}

variable "ingress_host" {
  description = "Hostname for the ingress"
  type        = string
  default = "kubecost.suvendupublicdomain.fun"
}

 

variable "tags" {
  description = "Tags for AWS resources"
  type        = map(string)
  default     = {}
}


variable prometheus_namespace {
  description = "Namespace where Prometheus is deployed"
  type        = string
  default     = "monitoring"
}