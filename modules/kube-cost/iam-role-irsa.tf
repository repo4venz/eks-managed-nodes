# modules/kubecost/main.tf
 

# IAM Role for Kubecost Service Account (IRSA)
resource "aws_iam_role" "kubecost" {
  name  = "${var.k8s_cluster_name}-kubecost-irsa-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.oidc.arn
      }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
        }
      }
    }]
  })
  tags = var.tags
}



resource "aws_iam_policy" "kubecost_policy" {
  name   = substr("${var.k8s_cluster_name}-kube-cost-policy",0,64)
  description = "IAM policy for Kube-Cost"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action =  [
                    "ce:GetCostAndUsage",
                    "ce:GetDimensionValues",
                    "ce:GetReservationUtilization",
                    "ce:GetSavingsPlansUtilization",
                    "ce:GetTags",
                    "ce:GetRightsizingRecommendation",
                    "ce:Get*",
                    "ce:Describe*",
                    "ce:List*",
                    "ec2:Describe*",
                    "pricing:GetProducts",
                    "s3:Get*",
                    "s3:List*",
                    "organizations:Describe*",
                    "organizations:List*",
                    "cur:DescribeReportDefinitions",
                    "ce:UntagResource",
                    "elasticfilesystem:CreateFileSystem",
                    "elasticfilesystem:DeleteFileSystem",   
                    "elasticfilesystem:DescribeFileSystems",
                    "elasticfilesystem:TagResource",
                    "elasticfilesystem:UntagResource",
                    "elasticfilesystem:CreateAccessPoint",
                    "elasticfilesystem:DeleteAccessPoint",
                    "elasticfilesystem:Describe*",
                    "elasticfilesystem:List*",
                    "elasticfilesystem:Create*"
			],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kubecost" {
  for_each   = toset([
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSResourceGroupsReadOnlyAccess",
  ])
  role       = aws_iam_role.kubecost.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "kubecost_custom" {
  role       = aws_iam_role.kubecost.name
  policy_arn = aws_iam_policy.kubecost_policy.arn
}
