resource "aws_iam_role" "kube_cost_role" {
  name  = substr("${var.k8s_cluster_name}-kube-cost-irsa-role",0,64)
  description = "IAM Role for Kube-Cost"
  assume_role_policy = data.aws_iam_policy_document.kube_cost_assume.json
}

resource "aws_iam_policy" "kube_cost_policy" {
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
                    "ec2:Describe*",
                    "pricing:GetProducts",
                    "s3:Get*",
                    "s3:List*",
                    "organizations:Describe*",
                    "organizations:List*",
                    "cur:DescribeReportDefinitions"
			],
        Resource = "*"
      }
    ]
  })
}


resource "helm_release" "kubecost" {
  name             = "kubecost"
  namespace        = "kubecost"
  repository       = "https://kubecost.github.io/cost-analyzer"
  chart            = "cost-analyzer"
  version          = var.kubecost_chart_version # Latest as of July 2025
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [
    yamlencode({
      kubecostToken = "e92a4573-3e3a-4cf9-81e0-4b05dfba9cc3"
      serviceAccount = {
        create = true
        name   = "kubecost-cost-analyzer"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.kube_cost_role.arn
        }
      }

      global = {
        prometheus = {
          enabled = true
        }
      }

      kubecostFrontend = {
        service = {
          type = "LoadBalancer" # Expose via ALB/NLB for access
        }
      }

      networkCosts = {
        enabled = true
      }

      # Optional: Disable product analytics (if required)
      productAnalytics = {
        enabled = false
      }
    })
  ]
}
