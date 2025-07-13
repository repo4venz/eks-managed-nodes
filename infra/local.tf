locals {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = module.eks.eks_cluster_endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.id
    eks_cluster_id                 = module.eks.eks_cluster_name
    eks_oidc_issuer_url            = module.eks.oidc_provider 
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
    eks_certificate_authority_data = module.eks.eks_cluster_certificate_authority_data 
    tags                           = var.tags

 max_pods = {
    "t3.large"    = 35
    "t3.xlarge"   = 58
    "t3.2xlarge"  = 110
    "m5.large"    = 29
    "m5.xlarge"   = 58
    "m5.2xlarge"  = 110
    "m5.4xlarge"  = 234
    "m5.8xlarge"  = 234
    "c5.4xlarge"  = 234
    "r5.8xlarge"  = 234
  }

}

