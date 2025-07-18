data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.k8s_cluster_name
}

 
 data "aws_iam_policy_document" "eks_use_kms_policy_ebs" {
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


 # AWS IAM Policy for KMS usage. Required for EKS to access KMS Key.
 resource "aws_iam_policy" "eks_ebs_kms_usage_policy" {
  name   = substr("${var.k8s_cluster_name}-AmazonEKS-EBS-KMS-UsagePolicy",0,64)
  policy = data.aws_iam_policy_document.eks_use_kms_policy_ebs.json
}
