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


 /*

 locals {
  # Max pods per instance type (using the AWS EKS formula: (ENIs * (IPs per ENI - 1)) + 2)
  max_pods = {
    "t3.large"    = 35   # 3 ENIs * (10-1) + 2 = 29 (AWS default), but can be increased
    "t3.xlarge"   = 58   # 4 ENIs * (15-1) + 2
    "t3.2xlarge"  = 58   # 4 ENIs * (15-1) + 2
    "r5.8xlarge"  = 234  # 8 ENIs * (30-1) + 2
    "c5.4xlarge"  = 234  # 8 ENIs * (30-1) + 2
  }

  # Base configuration for all node groups
  base_node_config = {
    desired_size = 2
    max_size     = 20
    min_size     = 2
  }

  # Spot instance types to include
  spot_instance_types = ["t3.xlarge", "t3.2xlarge"]

  # Generate node groups configuration
  node_groups = merge(
    # Static node groups (non-spot)
    {
      general_large = merge(local.base_node_config, {
        instance_type = "t3.large"
        max_pods      = local.max_pods["t3.large"]
      })
      high_mem = merge(local.base_node_config, {
        instance_type = "r5.8xlarge"
        desired_size  = 1
        max_pods      = local.max_pods["r5.8xlarge"]
      })
      high_cpu = merge(local.base_node_config, {
        instance_type = "c5.4xlarge"
        desired_size  = 1
        max_pods      = local.max_pods["c5.4xlarge"]
      })
    },
    # Dynamic spot node groups
    {
      for idx, instance_type in local.spot_instance_types : 
      "spot_${replace(instance_type, ".", "_")}" => merge(local.base_node_config, {
        instance_type = instance_type
        capacity_type = "SPOT"
        max_pods      = local.max_pods[instance_type]
      })
    }
  )
}

 */