data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.k8s_cluster_name
}

 data "aws_iam_policy_document" "eks_use_kms_policy_efs" {
	  statement {
	    sid = "KMSUsagePolicyEBS"
	    actions = [
	      "kms:Encrypt",
	      "kms:Decrypt",
	      "kms:GenerateDataKey*",
	      "kms:Describe*",
		  "kms:CreateGrant",
		  "kms:ReEncrypt*",
	    ]
	
	    resources = "*"
	  }
	}

