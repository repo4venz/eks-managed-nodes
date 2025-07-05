

data "aws_iam_policy_document" "kms_key_policy" {
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
