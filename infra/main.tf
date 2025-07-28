# infra/main.tf
# This file contains the main configuration for the EKS cluster and its associated resources.
module "vpc" {
    source                              = "../modules/vpc"
    environment                         =  var.environment
    vpc_cidr                            =  var.vpc_cidr
    vpc_name                            =  var.vpc_name
    cluster_name                        =  var.cluster_name
    cluster_group                       =  var.cluster_group
    public_subnets_cidr                 =  var.public_subnets_cidr
    availability_zones_public           =  var.availability_zones_public
    private_subnets_cidr                =  var.private_subnets_cidr
    availability_zones_private          =  var.availability_zones_private
    cidr_block_nat_gw                   =  var.cidr_block_nat_gw
    cidr_block_internet_gw              =  var.cidr_block_internet_gw
}

module kms_aws {
    source                              =  "../modules/kms-aws"
    cluster_name                        =  "${var.cluster_name}-${var.environment}"
    environment                         =  var.environment

    depends_on = [module.vpc]
}

module "eks" {
    source                                        =  "../modules/eks"
    cluster_name                                  =  local.k8s_cluster_name
    cluster_version                               =  var.cluster_version
    environment                                   =  var.environment
    private_subnets                               =  module.vpc.aws_subnets_private_ids    
    public_subnets                                =  module.vpc.aws_subnets_public_ids
    eks_kms_secret_encryption_key_arn             =  module.kms_aws.eks_kms_secret_encryption_key_arn  # KMS Key ID
    eks_kms_secret_encryption_alias_arn           =  module.kms_aws.eks_kms_secret_encryption_alias_arn  
	  eks_kms_cloudwatch_logs_encryption_key_arn    =  module.kms_aws.eks_kms_cloudwatch_logs_encryption_key_arn # KMS Key ID
    eks_kms_cloudwatch_logs_encryption_alias_arn  =  module.kms_aws.eks_kms_cloudwatch_logs_encryption_alias_arn 
    aws_admin_role_names                          =  var.aws_admin_role_names
    aws_admin_user_names                          =  var.aws_admin_user_names

    #include_ebs_csi_driver                        =  var.include_ebs_csi_driver
    #ebs_csi_helm_chart_version                    =  var.ebs_csi_helm_chart_version  
    #include_efs_csi_driver_addon                  =  var.include_efs_csi_driver_addon

    required_spot_instances                       =  var.required_spot_instances    ## only applicable to SPOT nodegroups with mixed EC2 types
    spot_instance_types                           =  var.spot_instance_types
    increase_spot_pod_density                     =  var.increase_spot_pod_density  ## only applicable to SPOT nodegroups with mixed EC2 types
    spot_node_groups_customised_config            =  local.spot_node_groups_customised_config ## Only applicable to individual SPOT nodegroups with INDIVIDUAL EC2 types + User defined number of PODs
    base_scaling_config_spot                      =  var.base_scaling_config_spot

    required_ondemand_instances                   =  var.required_ondemand_instances  ## only applicable to ON-DEMAND nodegroups with mixed EC2 types
    ondemand_instance_types                       =  var.ondemand_instance_types
    increase_ondemand_pod_density                 =  var.increase_ondemand_pod_density  ## only applicable to ON-DEMAND nodegroups with mixed EC2 types
    ondemand_node_groups_customised_config        =  local.ondemand_node_groups_customised_config ## Only applicable to individual ON-DEMAND nodegroups with INDIVIDUAL EC2 types + User defined number of PODs
    base_scaling_config_ondemand                  =  var.base_scaling_config_ondemand

    ebs_volume_size_in_gb                         =  var.ebs_volume_size_in_gb
    ebs_volume_type                               =  var.ebs_volume_type

    #Agentic AI LLM
    required_gpu_ondemand_instances                        =  var.required_gpu_ondemand_instances  ## Flag to indicate if LLM instances are required
    required_gpu_spot_instances                            =  var.required_gpu_spot_instances  ## Flag to indicate if LLM instances are required


    depends_on = [module.vpc, module.kms_aws]
}



module "ebs_storage" {
  source = "../modules/ebs-storage"
  count = var.include_ebs_csi_driver_module ? 1 : 0 
  
  k8s_cluster_name                              =   local.k8s_cluster_name
  ebs_csi_helm_chart_version                    =  var.ebs_csi_helm_chart_version

  depends_on = [module.eks]
}


module "efs_storage" {
    count = var.include_efs_csi_driver_module ? 1 : 0 

  source = "../modules/efs-storage"  
  k8s_cluster_name                              =   local.k8s_cluster_name
  efs_csi_helm_chart_version                    =   var.efs_csi_helm_chart_version
  vpc_id                                        =   module.vpc.vpc_id
  private_subnet_ids                            =   module.vpc.aws_subnets_private_ids
  eks_cluster_security_group_id                 =   module.eks.eks_cluster_primary_security_group_id 

   depends_on = [module.eks]
}


module "metrics_server" {
  count = var.include_metrics_server_module ? 1 : 0
  source             = "../modules/metrics-server"
  k8s_cluster_name   = local.k8s_cluster_name
  k8s_namespace      = "kube-system"
  metrics_server_chart_version = var.metrics_server_chart_version

  depends_on = [module.eks]
}


module "vpc-cni-addon" {
  count = var.include_vpc_cni_addon_module ? 1 : 0
  source                                        = "../modules/eks-add-ons/vpc-cni"
  k8s_cluster_name                              =  local.k8s_cluster_name

  depends_on = [module.eks]
}

module "kube-proxy-addon" {
  count = var.include_kube_proxy_addon_module ? 1 : 0
  source                                        = "../modules/eks-add-ons/kube-proxy"
  k8s_cluster_name                              =  local.k8s_cluster_name

  depends_on = [module.eks]
}

module "coredns-addon" {
  count = var.include_coredns_addon_module ? 1 : 0
  source                                        = "../modules/eks-add-ons/coredns"
  k8s_cluster_name                              =  local.k8s_cluster_name

  depends_on = [module.eks]
}

module "pod_indentity_agent" {
  count = var.include_pod_identity_agent_addon_module ? 1 : 0
  source                                        = "../modules/eks-add-ons/pod-identity-agent"
  k8s_cluster_name                              =  local.k8s_cluster_name

  depends_on = [module.eks]
}


module "calico" {
  count = var.include_calico_module ? 1 : 0
  source                                        = "../modules/calico"
  k8s_cluster_name                              =  local.k8s_cluster_name
  calico_chart_version                          =  var.calico_chart_version

  depends_on = [module.eks, module.vpc-cni-addon, module.coredns-addon, module.kube-proxy-addon, module.pod_indentity_agent]
}

module "nginx_alb_controller" {
  count = var.include_nginx_controller_module ? 1 : 0
  source         = "../modules/nginx-lb-controller"
  k8s_namespace  = "ingress-nginx"
  nginx_ingress_chart_version = var.nginx_ingress_chart_version

  depends_on = [module.eks, module.calico]
}


module "eks-cluster-autoscaler" {
  count = var.include_eks_cluster_autoscaler_module ? 1 : 0
  source                                        = "../modules/eks-cluster-autoscaler"
  k8s_cluster_name                              = local.k8s_cluster_name
  k8s_namespace                                 = "kube-system"

  depends_on = [module.eks]
}


 module "fluentbit" {
  count = var.include_fluentbit_module ? 1 : 0
  source                                        = "../modules/fluentbit"
  k8s_cluster_name                              =  local.k8s_cluster_name
  k8s_namespace                                 =  var.k8s_observability_namespace
  fluentbit_chart_version                       =  var.fluentbit_chart_version

  depends_on = [module.eks]
}


module "cert-manager" {
  count = var.include_cert_manager_module ? 1 : 0
  source                                        = "../modules/cert-manager"
  certmanager_chart_version                     =  var.certmanager_chart_version
  k8s_cluster_name                              =  local.k8s_cluster_name
  
  depends_on = [module.eks, module.nginx_alb_controller]
}

 
 