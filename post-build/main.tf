
module "lets-encrypt" {
  count = var.include_lets_encrypt_ca_module ? 1 : 0
  source             = "./modules/lets-encrypt"
  environment        =  var.environment
  acme_environment   = "prod"    # Let's Encrypt ACME env = prod is required for valid ssl certs in browser                         
  
 # depends_on = [module.cert-manager]
}


module "kube-cost" {
  count = var.include_kubecost_module ? 1 : 0
  source                    = "./modules/kube-cost"
  k8s_cluster_name          =  "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  kubecost_chart_version    =  var.kubecost_chart_version
  environment               =  var.environment
  ingress_host              =  "kubecost.${var.public_domain_name}"

  depends_on = [module.lets-encrypt]
}


module "external-secrets" {
  count = var.include_external_secrets_module ? 1 : 0
  source                        = "./modules/external-secrets"
  k8s_cluster_name              =  "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  external_secret_chart_version =  var.external_secret_chart_version
  aws_test_secrets              =  var.aws_test_secrets  ## This is only testing purpose

  #depends_on = [module.eks, module.nginx_alb_controller]
}

 /*

module "kubernetes_app" {
    count = var.include_k8s_app_module ? 1 : 0
    source                      =  "./modules/kubernetes-app"
    app_namespace               =  var.app_namespace[0]
    ingress_hostname            =  "game.${var.public_domain_name}"

  depends_on = [module.cert-manager]
}

module "kubernetes_app_secured" {
    count = var.include_k8s_app_secured_module ? 1 : 0
    source                      =  "./modules/kubernetes-app-secured"
    app_namespace               =  var.app_namespace[1]
    environment                 =  var.environment
    ingress_hostname            =  "game-secured.${var.public_domain_name}"

  depends_on = [module.lets-encrypt]
}
 */