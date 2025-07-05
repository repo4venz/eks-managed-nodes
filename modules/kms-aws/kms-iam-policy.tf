

data "aws_iam_policy_document" "kms_key_policy" {
  # Allow EKS to use the key (for secrets encryption)
  statement {
    sid     = "AllowEKS"
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]

    resources = ["*"]
  }
 # Allow EC2/EBS (for encrypted volumes)
  statement {
    sid     = "AllowEC2EBS"
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
      "kms:CreateGrant"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = ["ec2.${data.aws_region.current.id}.amazonaws.com"]
    }
  }
# Allow EC2 Node Role Access (for secrets encryption)
  statement {
    sid     = "AllowNodeRoleAccess"
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
      "kms:CreateGrant"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = ["ec2.${data.aws_region.current.id}.amazonaws.com"]
    }
  }

# Allow CloudWatch (e.g., Logs insights or metric streams)
  statement {
    sid     = "AllowCloudWatchLogs"
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.id}.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
      "kms:ReEncrypt*"
    ]

    resources = ["*"]
  }

 # Allow account root/admins full access
  statement {
    sid     = "AllowRootAccount"
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}
