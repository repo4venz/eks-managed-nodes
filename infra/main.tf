
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
    cluster_name                                  =  "${var.cluster_name}-${var.environment}" #var.cluster_name
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
    include_ebs_csi_driver_addon                  =  var.include_ebs_csi_driver_addon
    include_efs_csi_driver_addon                  =  var.include_efs_csi_driver_addon
    spot_instance_types                           =  var.spot_instance_types
    ondemand_instance_types                       =  var.ondemand_instance_types
    required_spot_instances                       =  var.required_spot_instances 
    required_ondemand_instances                   =  var.required_ondemand_instances
    scaling_config_spot                           =  var.scaling_config_spot
    scaling_config_ondemand                       =  var.scaling_config_ondemand
    ebs_volume_size_in_gb                         =  var.ebs_volume_size_in_gb
    ebs_volume_type                               =  var.ebs_volume_type

    depends_on = [module.vpc, module.kms_aws]
}
 

module "metrics_server" {
  count = var.include_metrics_server_module ? 1 : 0
  source             = "../modules/metrics-server"
  k8s_cluster_name   = "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  k8s_namespace  = "kube-system"
  metrics_server_chart_version = var.metrics_server_chart_version

  depends_on = [module.eks]
}


module "nginx_alb_controller" {
  count = var.include_nginx_controller_module ? 1 : 0
  source         = "../modules/nginx-lb-controller"
  k8s_namespace  = "ingress-nginx"
  nginx_ingress_chart_version = var.nginx_ingress_chart_version

  depends_on = [module.eks]
}

module "vpc-cni-addon" {
  count = var.include_vpc_cni_addon_module ? 1 : 0
  source                                        = "../modules/vpc-cni"
  k8s_cluster_name                              =  "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name

  depends_on = [module.eks]
}

module "eks-cluster-autoscaler" {
  count = var.include_eks_cluster_autoscaler_module ? 1 : 0
  source                                        = "../modules/eks-cluster-autoscaler"
  k8s_cluster_name                              = "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  k8s_namespace                                 = "kube-system"

  depends_on = [module.eks]
}


module "external-dns" {
  count = var.include_external_dns_module ? 1 : 0
  source                                        = "../modules/external-dns"
  k8s_cluster_name                              =  "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  k8s_namespace                                 = "kube-system"

  depends_on = [module.eks, module.nginx_alb_controller]
}


module "fluentbit" {
  count = var.include_fluentbit_module ? 1 : 0
  source                                        = "../modules/fluentbit"
  k8s_cluster_name                              =  "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  k8s_namespace                                 =  var.k8s_observability_namespace
  fluentbit_chart_version                       =  var.fluentbit_chart_version

  depends_on = [module.eks]
}

module "prometheus" {
  count = var.include_prometheus_module ? 1 : 0
  source                                        = "../modules/prometheus"
  k8s_cluster_name                              =  "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  k8s_namespace                                 =  var.k8s_observability_namespace
  prometheus_chart_version                      =  var.prometheus_chart_version

  depends_on = [module.eks, module.nginx_alb_controller, module.external-dns]
}


module "cert-manager" {
  count = var.include_cert_manager_module ? 1 : 0
  source                                        = "../modules/cert-manager"
  certmanager_chart_version                     =  var.certmanager_chart_version
  k8s_cluster_name                              =  "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  
  depends_on = [module.eks, module.nginx_alb_controller]
}

/*
module "lets-encrypt" {
  count = var.include_lets_encrypt_ca_module ? 1 : 0
  source             = "./modules/lets-encrypt"
  environment        =  var.environment
  acme_environment   = "prod"    # Let's Encrypt ACME env = prod is required for valid ssl certs in browser                         
  
  depends_on = [module.eks, module.cert-manager]
}
*/
/*
module "kube-cost" {
  count = var.include_kubecost_module ? 1 : 0
  source                    = "./modules/kube-cost"
  k8s_cluster_name          =  "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  kubecost_chart_version    =  var.kubecost_chart_version
  environment               =  var.environment
  ingress_host              =  "kubecost.${var.public_domain_name}"

  depends_on = [module.eks, module.nginx_alb_controller, module.external-dns, module.lets-encrypt]
}


module "external-secrets" {
  count = var.include_external_secrets_module ? 1 : 0
  source                        = "./modules/external-secrets"
  k8s_cluster_name              =  "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  external_secret_chart_version =  var.external_secret_chart_version
  aws_test_secrets              =  var.aws_test_secrets  ## This is only testing purpose

  depends_on = [module.eks, module.nginx_alb_controller]
}
*/
 /*

module "kubernetes_app" {
    count = var.include_k8s_app_module ? 1 : 0
    source                      =  "./modules/kubernetes-app"
    app_namespace               =  var.app_namespace[0]
    ingress_hostname            =  "game.${var.public_domain_name}"

  depends_on = [module.eks, module.nginx_alb_controller]
}

module "kubernetes_app_secured" {
    count = var.include_k8s_app_secured_module ? 1 : 0
    source                      =  "./modules/kubernetes-app-secured"
    app_namespace               =  var.app_namespace[1]
    environment                 =  var.environment
    ingress_hostname            =  "game-secured.${var.public_domain_name}"

  depends_on = [module.eks, module.nginx_alb_controller, module.cert-manager, module.lets-encrypt]
}
 */



 