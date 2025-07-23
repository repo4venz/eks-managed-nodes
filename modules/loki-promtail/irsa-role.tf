

# Create IAM role for Loki with IRSA
resource "aws_iam_role" "loki_role" {
  name               = "${var.k8s_cluster_name}-loki-role"
  assume_role_policy = data.aws_iam_policy_document.loki_assume_role.json
}

# Attach policies to the Loki role
resource "aws_iam_role_policy_attachment" "loki_policy_attachment" {
  role       = aws_iam_role.loki_role.name
  policy_arn = aws_iam_policy.loki_policy.arn
}

# Create IAM policy for Loki
resource "aws_iam_policy" "loki_policy" {
  name        = "${var.k8s_cluster_name}-loki-policy"
  description = "IAM policy for Loki"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.loki_storage_bucket}",
          "arn:aws:s3:::${var.loki_storage_bucket}/*"
        ]
      }
    ]
  })
}
