variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where EKS cluster is deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "eks_cluster_security_group_id" {
  description = "Security group ID of the EKS cluster"
  type        = string
}

variable "eks_kms_secret_encryption_alias_arn" {
  description = "KMS key (alias) ARN for EKS"
  type        = string
}