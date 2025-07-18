
 
 

# Define service accounts and IRSA for apps1 and apps2
 
resource "aws_iam_role" "eso_app_irsa" {
#for_each = { for idx, secret in var.aws_test_secrets : idx => secret.application_namespace }

for_each = toset(var.app_namespace)
 name  = substr("${var.k8s_cluster_name}-eso-app-irsa-role-${each.value}",0,64)
 
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
          "${replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:${each.value}:${each.value}-eso-sa"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "eso_app_irsa_policy" {
  name        = substr("${var.k8s_cluster_name}-eso-app-access-policy",0,64)
  description = "Allow access to SecretsManager and Parameter Store doe applications"

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

resource "aws_iam_role_policy_attachment" "eso_app_irsa_attachment" {
#for_each = { for idx, secret in var.aws_test_secrets : idx => secret.application_namespace }

for_each = toset(var.app_namespace)
  role       = aws_iam_role.eso_app_irsa[each.key].name
  policy_arn = aws_iam_policy.eso_app_irsa_policy.arn
}


resource "kubernetes_service_account" "eso_app_sa" {
  #for_each = { for idx, secret in var.aws_test_secrets : idx => secret.application_namespace }
for_each = toset(var.app_namespace)
  metadata {
    name      = "${each.value}-eso-sa"
    namespace = each.key
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eso_app_irsa[each.key].arn
    }
  }
      depends_on = [ null_resource.create_namespaces_if_not_exists ]
}
