 
resource "aws_iam_role" "fluentbit" {
  name  = substr("${var.k8s_cluster_name}-fluentbit-irsa-role",0,64)
  description = "IAM Role for FluentBit for CloudWatch"
  assume_role_policy = data.aws_iam_policy_document.fluentbit_assume.json
}


 resource "aws_iam_policy" "fluentbit" {
  name   = substr("${var.k8s_cluster_name}-fluentbit-cloudwatch-policy",0,64)
  description = "IAM policy for FluentBit for CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fluentbit_attach" {
  role       = aws_iam_role.fluentbit.name
  policy_arn = aws_iam_policy.fluentbit.arn
}

/*
resource "aws_cloudwatch_log_group" "fluentbit" {
  name              = "/aws/eks/${data.aws_eks_cluster.this.name}/fluentbit/logs"
  retention_in_days = 7
}

/*
resource "helm_release" "fluentbit" {
  name             = "fluent-bit"
  namespace        = var.k8s_namespace
  create_namespace = true
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluent-bit"
  version          = var.fluentbit_chart_version # Latest as of July 2025
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = "fluent-bit"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.fluentbit.arn
        }
      }

      cloudwatch = {
        enabled     = true
        region      = data.aws_region.current.id
        logGroupName = aws_cloudwatch_log_group.fluentbit.name
        logStreamPrefix = "fluentbit-"
        autoCreateGroup = false
      }

      output = {
        cloudwatch = {
          enabled = true
        }
      }

      input = {
        kubernetes = {
          enabled = true
        }
      }
    })
  ]

  depends_on = [aws_iam_role_policy_attachment.fluentbit_attach,
  aws_iam_role.fluentbit,
  aws_cloudwatch_log_group.fluentbit]
}

*/

resource "helm_release" "fluentbit" {
  name             = "fluent-bit"
  namespace        = var.k8s_namespace
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluent-bit"
  version          = var.fluentbit_chart_version # Latest as of July 2025
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [
    templatefile("${path.module}/fluentbit-config-values.yaml", {
      region      = data.aws_region.current.id
      log_group   = "/aws/eks/${data.aws_eks_cluster.this.name}/fluentbit/logs" #aws_cloudwatch_log_group.fluentbit.name
      role_arn    = aws_iam_role.fluentbit.arn
    })
  ]

  depends_on = [aws_iam_role_policy_attachment.fluentbit_attach,
  aws_iam_role.fluentbit,
  aws_cloudwatch_log_group.fluentbit]

}