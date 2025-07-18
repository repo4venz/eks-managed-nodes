 

resource "aws_iam_role_policy_attachment" "external_dns_attach" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  version          = var.external_dns_chart_version
  namespace        = var.k8s_namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 900

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = "external-dns"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
        }
      }
      rbac = { create = true }
      provider = "aws"
      policy   = "sync"
      registry = "txt"
      sources  = ["service", "ingress"]
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.external_dns_attach,
    aws_iam_role.external_dns
  ]
}
