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
  # https://github.com/awslabs/amazon-eks-ami/blob/main/nodeadm/internal/kubelet/eni-max-pods.txt
    # Max pods per instance type (using the AWS EKS formula: Default : (ENIs * (IPs per ENI - 1)) + 2)
                         # (AWS default), but can be increased
  # Max PODs when Prefix Delegation Enabled = (Number of network interfaces for the instance type × (the number of slots per network interface - 1)* 16)
    "t3.medium"   = 20
    "t3.large"    = 35   # 3 ENIs * (10-1) + 2 = 29 (AWS default), but can be increased
    "t3.xlarge"   = 65   # 4 ENIs * (15-1) + 2 = 58
    "t3.2xlarge"  = 90   # 4 ENIs * (12-1) + 2 = 45
    "m5.large"    = 45   # (3 ENIs × (10 IPs - 1)) + 2 = 29 pods  (2 IPs reserved for Kubernetes system pods)
    "m5.xlarge"   = 64   # (4 × (15 − 1)) + 2 = 58
    "m5.2xlarge"  = 110  # (4 ENIs × 15 IPs) - 1 (primary ENI IP) = 59 Kubelet --max-pods	Set to ≤ 59 (recommended: 58 for buffer) 
    "m5.4xlarge"  = 234
    "m5.8xlarge"  = 234
    "r5.8xlarge"  = 234  # 8 ENIs * (30-1) + 2 = 234
    "c5.4xlarge"  = 234  # 8 ENIs * (30-1) + 2 = 234
  }
 
 

    # Calculate final max_pods with overrides for SPOT Instances
  spot_node_groups_customised_config = var.enable_spot_pod_density_customised ? {
    for instance_type in var.spot_instance_types :
    instance_type => {
      instance_type = instance_type

      desired_size     = coalesce(
        try(var.overrides_spot_node_scale_config[instance_type].desired_size, null),
        var.base_scaling_config_spot.desired_size
      )

      min_size     = coalesce(
        try(var.overrides_spot_node_scale_config[instance_type].min_size, null),
        var.base_scaling_config_spot.min_size
      )

      max_size     = coalesce(
        try(var.overrides_spot_node_scale_config[instance_type].max_size, null),
        var.base_scaling_config_spot.max_size
      )
 
      max_pods     = coalesce(
        try(var.overrides_spot_node_scale_config[instance_type].max_pods, null),
        lookup(local.max_pods, instance_type) 
      )
    }
   } : {}




    # Calculate final max_pods with overrides for ON-DEMAND Instances
  ondemand_node_groups_customised_config = var.enable_ondemand_pod_density_customised ? {
    for instance_type in var.ondemand_instance_types :
    instance_type => {
      instance_type = instance_type

      desired_size     = coalesce(
        try(var.overrides_ondemand_node_scale_config[instance_type].desired_size, null),
        var.base_scaling_config_ondemand.desired_size
      )

      min_size     = coalesce(
        try(var.overrides_ondemand_node_scale_config[instance_type].min_size, null),
        var.base_scaling_config_ondemand.min_size
      )

      max_size     = coalesce(
        try(var.overrides_ondemand_node_scale_config[instance_type].max_size, null),
        var.base_scaling_config_ondemand.max_size
      )
 
      max_pods     = coalesce(
        try(var.overrides_ondemand_node_scale_config[instance_type].max_pods, null),
        lookup(local.max_pods, instance_type) 
      )
    }
   } : {}

}

  

  /*

  MAP looks like:


 + debug_spot_node_groups_customised_config = {
2025-07-13T22:39:16.6867043Z       + "m5.2xlarge" = {
2025-07-13T22:39:16.6867234Z           + desired_size  = 2
2025-07-13T22:39:16.6867462Z           + instance_type = "m5.2xlarge"
2025-07-13T22:39:16.6867654Z           + max_pods      = 110
2025-07-13T22:39:16.6867842Z           + max_size      = 20
2025-07-13T22:39:16.6868033Z           + min_size      = 1
2025-07-13T22:39:16.6868132Z         }
2025-07-13T22:39:16.6868309Z       + "t3.2xlarge" = {
2025-07-13T22:39:16.6868501Z           + desired_size  = 2
2025-07-13T22:39:16.6868820Z           + instance_type = "t3.2xlarge"
2025-07-13T22:39:16.6869015Z           + max_pods      = 58
2025-07-13T22:39:16.6869202Z           + max_size      = 20
2025-07-13T22:39:16.6869401Z           + min_size      = 1
2025-07-13T22:39:16.6869506Z         }
2025-07-13T22:39:16.6869688Z       + "t3.xlarge"  = {
2025-07-13T22:39:16.6869873Z           + desired_size  = 3
2025-07-13T22:39:16.6870188Z           + instance_type = "t3.xlarge"
2025-07-13T22:39:16.6870377Z           + max_pods      = 58
2025-07-13T22:39:16.6870561Z           + max_size      = 20
2025-07-13T22:39:16.6870756Z           + min_size      = 1
2025-07-13T22:39:16.6870846Z         }
2025-07-13T22:39:16.6870941Z     }

*/