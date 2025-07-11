locals {
  addon_context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = data.aws_eks_cluster.this.endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.id
    eks_cluster_id                 = data.aws_eks_cluster.this.name
    eks_oidc_issuer_url            = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${data.aws_eks_cluster.this.identity[0].oidc[0].issuer}"
    eks_certificate_authority_data = try(base64decode(data.aws_eks_cluster.this.certificate_authority[0].data), "")
    tags                           = var.tags
  }
}
