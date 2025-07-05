data "aws_iam_policy_document" "eks_use_kms_policy" {
	  statement {
	    sid = "KMSUsagePolicy"
	    actions = [
	      "kms:Encrypt",
	      "kms:Decrypt",
	      "kms:GenerateDataKey*",
	      "kms:Describe*",
		  "kms:CreateGrant",
		  "kms:ReEncrypt*",
	    ]
	
	    resources = [
	     var.eks_kms_secret_encryption_key_arn,
         var.eks_kms_secret_encryption_alias_arn
	    ]
	  }
	}


 # AWS IAM Policy for KMS usage. Required for EKS to access KMS Key.
 resource "aws_iam_policy" "EKS_KMS_Usage_Policy" {
  name   = substr("${var.cluster_name}-${var.environment}-AmazonEKS-KMS-UsagePolicy",0,64)
  policy = data.aws_iam_policy_document.eks_use_kms_policy.json
}
