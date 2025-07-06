 
resource "aws_iam_policy" "fluentbit" {
  name = substr("${var.k8s_cluster_name}-fluentbit-cloudwatch-policy",0,64)
  description = "IAM policy for FluentBit for CloudWatch"
  policy      = file("${path.module}/fluentbit-policy.json")
}

 
resource "aws_iam_role" "fluentbit" {
  name = substr("${var.k8s_cluster_name}-fluentbit-irsa-role",0,64)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.this.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(data.aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" = "system:serviceaccount:${var.k8s_namespace}:fluent-bit"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "fluentbit_attach" {
  role       = aws_iam_role.fluentbit.name
  policy_arn = aws_iam_policy.fluentbit.arn
}


resource "aws_cloudwatch_log_group" "fluentbit" {
  name              = "/aws/eks/${data.aws_eks_cluster.this.name}/fluentbit/logs"
  retention_in_days = 7
}


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
        region      = "eu-west-2"
        logGroupName = "/aws/eks/eks-managed-clstr-dev/fluentbit/logs"
        logStreamPrefix = "fluentbit-" 
        autoCreateGroup = true
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
