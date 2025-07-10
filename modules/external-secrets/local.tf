locals {
  external_secrets_values = yamlencode({
    installCRDs = true

    webhook = {
      port = 9443
    }

    clusterName = var.k8s_cluster_name
    region      = data.aws_region.current.id

    serviceAccount = {
      create = true
      name   = var.service_account_name
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets_irsa.arn
      }
    }
    provider = {
      aws = {
        service = "SecretsManager"
      }
    }
  })
}
