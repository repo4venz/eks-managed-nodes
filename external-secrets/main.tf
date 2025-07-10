resource "aws_iam_role" "external_secrets_irsa" {
 name  = "${var.k8s_cluster_name}-external-secrets-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.oidc.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "external_secrets_policy" {
  name        = "${var.k8s_cluster_name}-external-secrets-access_policy"
  description = "Allow access to SecretsManager and Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_secrets_attachment" {
  role       = aws_iam_role.external_secrets_irsa.name
  policy_arn = aws_iam_policy.external_secrets_policy.arn
}


resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.external_secret_chart_version
  namespace        = var.namespace
  create_namespace = true
  atomic           = true
  timeout          = 900
  cleanup_on_fail  = true

  values = [local.external_secrets_values]

  depends_on = [
    aws_iam_role_policy_attachment.external_secrets_attachment,
    aws_iam_role.external_secrets_irsa
    ]
}


