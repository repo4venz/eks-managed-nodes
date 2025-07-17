variable "cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}


variable "private_subnets" {
  description = "List of private subnet IDs"
}

variable "public_subnets" {
  description = "List of private subnet IDs"
}

 

variable "cluster_version" {
  description = "Version of the EKS Cluster"
  default = "1.33"
}



variable "eks_kms_secret_encryption_key_arn" {
	    description = "kms key id/arn for eks"
	}

variable "eks_kms_secret_encryption_alias_arn" {
	    description = "kms key (alias) arn for eks"
	}

 
 variable "eks_kms_cloudwatch_logs_encryption_key_arn" {
	    description = "kms key id/arn for CloudWatch"
	}

variable "eks_kms_cloudwatch_logs_encryption_alias_arn" {
	    description = "kms key (alias) arn for CloudWatch"
	}
 

variable "eks_readiness_timeout" {
  description = "The maximum time (in seconds) to wait for EKS API server endpoint to become healthy"
  type        = number
  default     = "600"
}


variable "aws_admin_role_name" {
  description = "AWS Admin Role to manage EKS cluster. The role must be created in AWS with required permission."
}

variable "aws_admin_user_name" {
  description = "AWS User who will assume AWS Admin Role to manage EKS cluster. The user must be created in AWS to assume the admin role."
}

variable "include_ebs_csi_driver" {
  description = "Execute module/feature or not. true = execute and false = don't execute"
  default = true
}

variable "include_efs_csi_driver_addon" {
  description = "Execute module/feature or not. true = execute and false = don't execute"
  default = true
}

variable "spot_instance_types" {
  description = "EKS worker nodes Spot instance types"
  type        = list(string)
  default     = ["t3.medium", "t3.large", "t3.small"]
}

variable "ondemand_instance_types" {
  description = "EKS worker nodes On-Demand instance types"
  type        = list(string)
  default     = ["t2.medium", "t2.large", "t2.small"]
}

variable "required_spot_instances" {
  description = "EKS worker nodes Spot instance types"
  type        = bool
  default     = true
}

variable "enable_spot_pod_density_customised" {
  description = "EKS worker nodes Spot instance types"
  type        = bool
  default     = false
}


variable "required_ondemand_instances" {
  description = "Execute module/feature or not. true = execute and false = don't execute"
  type        = bool
  default     = false
}

variable "increase_spot_pod_density" {
  type        = bool
  default     = false
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "increase_ondemand_pod_density" {
  type        = bool
  default     = false
  description = "Execute module or not. true = execute and false = don't execute"
}



variable "base_scaling_config_spot" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  default = {
    desired_size = 3
    max_size     = 6
    min_size     = 1
  }
}


variable "base_scaling_config_ondemand" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  default = {
    desired_size = 2
    max_size     = 6
    min_size     = 1
  }
}


variable "ebs_volume_size_in_gb" {
  type        = number
  description = "EKS Worker Node EBS Volume Size for SPOT and On_DEMAND instances"
  default     = 20
}

variable "ebs_volume_type" {
  type        = string
  description = "EKS Worker Node EBS Volume Type for SPOT and On_DEMAND instances"
  default     = "gp3"
}
 
variable "ebs_volume_iops" {
  type        = number
  description = "EKS Worker Node EBS Volume IOPS for SPOT and On_DEMAND instances"
  default     = 3000
}

variable "ebs_volume_throughput" {
  type        = number
  description = "EKS Worker Node EBS Volume Throughput for SPOT and On_DEMAND instances"
  default     = 125
}

variable ebs_csi_service_account_name {
  description = "Service Account Name for EBS CSI Driver"
  type        = string
  default     = "ebs-csi-controller-sa"
}

variable "efs_csi_service_account_name" {
  description = "Service Account Name for EFS CSI Driver"
  type        = string
  default     = "efs-csi-controller-sa"
}

variable "ebs_csi_helm_chart_version" {
  description = "Helm chart version for EBS CSI Driver"
  type        = string
  default     = "2.46.0"  # Check for latest version
}
 
 variable "spot_node_groups_customised_config" {
  description = "Map of instance types and their scaling configuration"
  type = map(object({
    instance_type = string
    desired_size  = number
    max_pods      = number
    max_size      = number
    min_size      = number
  }))

  default = { }
}


 variable "ondemand_node_groups_customised_config" {
  description = "Map of instance types and their scaling configuration"
  type = map(object({
    instance_type = string
    desired_size  = number
    max_pods      = number
    max_size      = number
    min_size      = number
  }))

  default = { }
}

variable "eks_optimized_ami_type" {
  description = "AMI Tpes used in EKS worker nodes. It would be a EKS Optimized AMIs"
  default = "AL2023_x86_64"  # Amazon Linux 2023 (AL2023)
}