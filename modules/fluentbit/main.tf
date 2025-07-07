 
resource "aws_iam_role" "fluentbit_role" {
  name  = substr("${var.k8s_cluster_name}-fluentbit-irsa-role",0,64)
  description = "IAM Role for FluentBit for CloudWatch"
  assume_role_policy = data.aws_iam_policy_document.fluentbit_assume.json
}

/*
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
*/

resource "aws_iam_policy" "fluentbit_policy" {
  name   = substr("${var.k8s_cluster_name}-fluentbit-cloudwatch-policy",0,64)
  description = "IAM policy for FluentBit for CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action =  [
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents",
				"logs:DescribeLogStreams",
				"logs:DescribeLogGroups",
				"logs:*",
				"cloudwatch:*"
			],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "fluentbit_attach" {
  role       = aws_iam_role.fluentbit_role.name
  policy_arn = aws_iam_policy.fluentbit_policy.arn
}

/*
resource "aws_cloudwatch_log_group" "fluentbit" {
  name              = "/aws/eks/${data.aws_eks_cluster.this.name}/fluentbit/logs"
  retention_in_days = 7
}
*/
 
resource "helm_release" "fluentbit" {
  name             = "aws-fluent-bit"
  namespace        = var.k8s_namespace
  create_namespace = true
  repository       = "https://aws.github.io/eks-charts" # "https://fluent.github.io/helm-charts"
  chart            = "aws-for-fluent-bit" #"fluent-bit"
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
          "eks.amazonaws.com/role-arn" = aws_iam_role.fluentbit_role.arn
        }
      }

      cloudWatch = {
        enabled     = true
        region      = data.aws_region.current.id
        logGroupName = "/aws/eks/${data.aws_eks_cluster.this.name}/fluentbit/logs" # aws_cloudwatch_log_group.fluentbit.name
        logStreamPrefix = "fluentbit-"
        logRetentionDays = 7
        autoCreateGroup = true
      }

      firehose = {
        enabled = false
      }

      kinesis = {
        enabled = false
      }

      elasticsearch = {
        enabled = false
      }

      kubernetes = {
        enabled = true
      }

      logs = {
        level = "debug"
      }
    })
  ]

  depends_on = [
  aws_iam_role_policy_attachment.fluentbit_attach,
  aws_iam_role.fluentbit_role #,
  #aws_cloudwatch_log_group.fluentbit
  ]
}



/*
resource "helm_release" "fluentbit" {
  name             = "fluent-bit"
  namespace        = var.k8s_namespace
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluent-bit"
  version          = var.fluentbit_chart_version # Latest as of July 2025
  atomic           = true
  cleanup_on_fail  = true
  create_namespace = true
  timeout    = 900

  values = [
    templatefile("${path.module}/fluentbit-config-values.yaml", {
      region      = "eu-west-2" #data.aws_region.current.id
      log_group   = "/aws/eks/fluentbit/logs" #aws_cloudwatch_log_group.fluentbit.name
      role_arn    = aws_iam_role.fluentbit_role.arn
    })
  ]

  depends_on = [
  aws_iam_role_policy_attachment.fluentbit_attach,
  aws_iam_role.fluentbit_role #,
  #aws_cloudwatch_log_group.fluentbit
  ]

}
*/