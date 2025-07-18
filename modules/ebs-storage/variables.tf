variable "k8s_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}


variable "ebs_volume_type" {
  type        = string
  description = "EKS Worker Node EBS Volume Type for SPOT and On_DEMAND instances"
  default     = "gp3"
}
 
variable "ebs_volume_iops" {
  type        = string
  description = "EKS Worker Node EBS Volume IOPS for SPOT and On_DEMAND instances"
  default     = "3000"
}

variable "ebs_volume_throughput" {
  type        = string
  description = "EKS Worker Node EBS Volume Throughput for SPOT and On_DEMAND instances"
  default     = "125"
}

variable ebs_csi_service_account_name {
  description = "Service Account Name for EBS CSI Driver"
  type        = string
  default     = "ebs-csi-controller-sa"
}

variable "ebs_csi_helm_chart_version" {
  description = "Helm chart version for EBS CSI Driver"
  type        = string
  default     = "2.46.0"  # Check for latest version
}

 
variable "eks_kms_secret_encryption_alias_arn" {
	    description = "kms key (alias) arn for eks"
	}
