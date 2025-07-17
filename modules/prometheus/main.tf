
 
resource "aws_iam_role" "prometheus_role" {
  name  =  substr("${var.k8s_cluster_name}-prometheus-iam-role",0,64)
  
  assume_role_policy = data.aws_iam_policy_document.prometheus_assume_role.json
}

resource "aws_iam_role_policy" "prometheus_policy" {
  name = substr("${var.k8s_cluster_name}-prometheus-policy",0,64)
  role = aws_iam_role.prometheus_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "ec2:Describe*",
          "autoscaling:Describe*",
          "eks:List*",
          "autoscaling:DescribeAutoScalingGroups",
          "logs:DescribeLogGroups",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}




resource "helm_release" "prometheus" {
  name       = "kube-prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.k8s_namespace
  version    = var.prometheus_chart_version
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [
    yamlencode({
      serviceAccounts = {
        server = {
          name        = "${var.prometheus_service_account_name}"
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.prometheus_role.arn
          }
        }
      } 
    }),
    file("${path.module}/prometheus-values.yaml")
  ]

  depends_on = [
    aws_iam_role.prometheus_role,
    aws_iam_role_policy.prometheus_policy
  ]
}

 