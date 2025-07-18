resource "aws_iam_policy" "external_dns" {
  name = substr("${var.k8s_cluster_name}-ExternalDNS-Policy",0,64)
  description = "IAM policy for ExternalDNS"
  policy      = file("${path.module}/external-dns-policy.json")
}

resource "aws_iam_role" "external_dns" {
  name = substr("${var.k8s_cluster_name}-ExternalDNS-IRSA-role",0,64)

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
          "${replace(data.aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" = "system:serviceaccount:${var.k8s_namespace}:external-dns"
        }
      }
    }]
  })
}
