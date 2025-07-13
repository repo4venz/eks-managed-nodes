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
    # Max pods per instance type (using the AWS EKS formula: (ENIs * (IPs per ENI - 1)) + 2)
    "t3.large"    = 35   # 3 ENIs * (10-1) + 2 = 29 (AWS default), but can be increased
    "t3.xlarge"   = 58   # 4 ENIs * (15-1) + 2
    "t3.2xlarge"  = 58   # 4 ENIs * (15-1) + 2
    "r5.8xlarge"  = 234  # 8 ENIs * (30-1) + 2
    "c5.4xlarge"  = 234  # 8 ENIs * (30-1) + 2
    "m5.large"    = 29
    "m5.xlarge"   = 58
    "m5.2xlarge"  = 110
    "m5.4xlarge"  = 234
    "m5.8xlarge"  = 234
  }
 
 

    # Calculate final max_pods with overrides
  spot_node_groups_max_pods = {
   for_each = var.required_spot_instances_max_pods ? {
    for instance_type in var.spot_instance_types :
    instance_type => {
      instance_type = instance_type
      desired_size = try(var.overrides_node_scale_config[instance_type].desired_size, var.scaling_config_spot.desired_size)
      min_size     = try(var.overrides_node_scale_config[instance_type].min_size, var.scaling_config_spot.min_size)
      max_size     = try(var.overrides_node_scale_config[instance_type].max_size, var.scaling_config_spot.max_size)
      #max_pods     = try(var.overrides_node_scale_config[instance_type].max_pods, local.max_pods[instance_type])

      max_pods     = coalesce(
        try(var.overrides_node_scale_config[instance_type].max_pods, null),
        lookup(local.max_pods, instance_type) 
      )
    }
   } : {}
  } 
 
}

  