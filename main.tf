
module "vpc" {
    source                              = "./modules/vpc"
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
    source                              =  "./modules/kms-aws"
    cluster_name                        =  var.cluster_name
    environment                         =  var.environment

    depends_on = [module.vpc]
}

module "eks" {
    source                                        =  "./modules/eks"
    cluster_name                                  =  var.cluster_name
    cluster_version                               =  var.cluster_version
    environment                                   =  var.environment
    private_subnets                               =  module.vpc.aws_subnets_private    
    public_subnets                                =  module.vpc.aws_subnets_public
    eks_kms_secret_encryption_key_arn             =  module.kms_aws.eks_kms_secret_encryption_key_arn  # KMS Key ID
    eks_kms_secret_encryption_alias_arn           =  module.kms_aws.eks_kms_secret_encryption_alias_arn  
	  eks_kms_cloudwatch_logs_encryption_key_arn    =  module.kms_aws.eks_kms_cloudwatch_logs_encryption_key_arn # KMS Key ID
    eks_kms_cloudwatch_logs_encryption_alias_arn  =  module.kms_aws.eks_kms_cloudwatch_logs_encryption_alias_arn 
    aws_admin_role_name                           =  var.aws_admin_role_name
    aws_admin_user_name                           =  var.aws_admin_user_name
    ebs_csi_driver_addon_flag                     =  var.include_ebs_csi_driver_addon

    depends_on = [module.vpc, module.kms_aws]
}



module "metrics_server" {
  count = var.include_metrics_server_module ? 1 : 0
  source             = "./modules/metrics-server"
  k8s_cluster_name   = module.eks.eks_cluster_name
  k8s_namespace  = "observability"

  depends_on = [module.eks]
}

module "nginx_alb_controller" {
  count = var.include_nginx_controller_module ? 1 : 0
  source         = "./modules/nginx-lb-controller"
  k8s_namespace  = "ingress-nginx"

  depends_on = [module.eks]
}


module "eks-cluster-autoscaler" {
  count = var.include_eks_cluster_autoscaler_module ? 1 : 0
  source                                        = "./modules/eks-cluster-autoscaler"
  k8s_cluster_name                              = module.eks.eks_cluster_name
  k8s_namespace                                 = "kube-system"

  depends_on = [module.eks]
}


module "external-dns" {
  count = var.include_external_dns_module ? 1 : 0
  source                                        = "./modules/external-dns"
  k8s_cluster_name                              =  module.eks.eks_cluster_name
  k8s_namespace                                 = "kube-system"

  depends_on = [module.eks]
}


module "fluentbit" {
  count = var.include_fluentbit_module ? 1 : 0
  source                                        = "./modules/fluentbit"
  k8s_cluster_name                              =  module.eks.eks_cluster_name
  k8s_namespace                                 = "observability"

  depends_on = [module.eks]
}


