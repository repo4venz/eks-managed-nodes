data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.k8s_cluster_name
}

 data "aws_iam_policy_document" "eks_use_kms_policy_efs" {
	  statement {
	    sid = "KMSUsagePolicy-EBS"
	    actions = [
	      "kms:Encrypt",
	      "kms:Decrypt",
	      "kms:Describe*",
		    "kms:CreateGrant",
	    ]
	
	    resources = [
         var.eks_kms_secret_encryption_alias_arn
	    ]
	  }
	}

