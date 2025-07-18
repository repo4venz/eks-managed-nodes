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

resource "aws_iam_role_policy_attachment" "external_dns_attach" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  version          =  var.external_dns_chart_version   #"1.17.0" # check for latest compatible version
  namespace        = var.k8s_namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = "external-dns"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
        }
      }
      rbac = {
        create = true
      }
      provider = "aws"
      policy   = "sync"
      registry = "txt"
      #txtOwnerId = var.txt_owner_id
      #domainFilters = var.domain_filters
      sources = ["service", "ingress"]
    })
  ]

  depends_on = [aws_iam_role_policy_attachment.external_dns_attach,
  aws_iam_role.external_dns]
}
