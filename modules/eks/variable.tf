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

variable "include_ebs_csi_driver_addon" {
  description = "Execute module/feature or not. true = execute and false = don't execute"
  default = true
}

variable "include_efs_csi_driver_addon" {
  description = "Execute module/feature or not. true = execute and false = don't execute"
  default = true
}
 
 