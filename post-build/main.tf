
 



module "external-dns" {
  count = var.include_external_dns_module ? 1 : 0
  source                                        = "../modules/external-dns"
  k8s_cluster_name                              =  "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  k8s_namespace                                 = "kube-system"

 # depends_on = [module.cert-manager]
}



module "prometheus" {
  count = var.include_prometheus_module ? 1 : 0
  source                                        = "../modules/prometheus"
  k8s_cluster_name                              =  "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  k8s_namespace                                 =  var.k8s_observability_namespace
  prometheus_chart_version                      =  var.prometheus_chart_version

  depends_on = [module.external-dns]
}


module "lets-encrypt" {
  count = var.include_lets_encrypt_ca_module ? 1 : 0
  source             = "../modules/lets-encrypt"
  environment        =  var.environment
  acme_environment   = "prod"    # Let's Encrypt ACME env = prod is required for valid ssl certs in browser                         
  
  depends_on = [module.external-dns ]
}




module "external-secrets-controller" {
  count = var.include_external_secrets_module ? 1 : 0
  source                        = "../modules/external-secrets-controller"
  k8s_cluster_name              =  "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  external_secret_chart_version =  var.external_secret_chart_version
 # aws_test_secrets              =  var.aws_test_secrets  ## This is only testing purpose

 # depends_on = [module.cert-manager]
}


module "kube-cost" {
  count = var.include_kubecost_module ? 1 : 0
  source                    = "../modules/kube-cost"
  k8s_cluster_name          =  "${var.cluster_name}-${var.environment}" #module.eks.eks_cluster_name
  kubecost_chart_version    =  var.kubecost_chart_version
  environment               =  var.environment
  ingress_host              =  "kubecost.${var.public_domain_name}"

  depends_on = [module.lets-encrypt, module.external-dns]
}
 