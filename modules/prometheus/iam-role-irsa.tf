
 
resource "aws_iam_role" "prometheus_role" {
  name  =  substr("${var.k8s_cluster_name}-prometheus-iam-role",0,64)  
  assume_role_policy = data.aws_iam_policy_document.prometheus_assume_role.json
}

 
resource "aws_iam_policy" "kubecost_policy" {
  name   = substr("${var.k8s_cluster_name}-prometheus-policy",0,64)
  description = "IAM Custom policy for Prometheus"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action =  [
                    "cloudwatch:GetMetricData",
                    "cloudwatch:GetMetricStatistics",
                    "cloudwatch:ListMetrics",
                     "autoscaling:Describe*",
                     "logs:GetLogEvents",
                    "logs:FilterLogEvents",
                    "ce:GetCostAndUsage",
                    "ce:GetDimensionValues",
                    "ce:GetReservationUtilization",
                    "ce:GetSavingsPlansUtilization",
                    "ce:GetTags",
                    "eks:List*",
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



resource "aws_iam_role_policy_attachment" "prometheus_policy_attachment" {
  for_each   = toset([
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSResourceGroupsReadOnlyAccess",
  ])
  role       = aws_iam_role.prometheus_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "prometheus_policy_custom" {
  role       = aws_iam_role.prometheus_role.name
  policy_arn = aws_iam_policy.kubecost_policy.arn
}
