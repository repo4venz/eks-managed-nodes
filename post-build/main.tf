
 
# post-build/main.tf
# This file contains the post-build configuration for the EKS cluster and its associated resources.

module "external-dns" {
  count = var.include_external_dns_module ? 1 : 0
  source                                        = "../modules/external-dns"
  k8s_cluster_name                              =  local.k8s_cluster_name
  k8s_namespace                                 = "kube-system"

 # depends_on = [module.cert-manager]
}

module "lets-encrypt" {
  count = var.include_lets_encrypt_ca_module ? 1 : 0
  source             = "../modules/lets-encrypt"
  environment        =  var.environment
  acme_environment   = "prod"    # Let's Encrypt ACME env = prod is required for valid ssl certs in browser                         
  
  depends_on = [module.external-dns ]
}



module "prometheus" {
  count = var.include_prometheus_module ? 1 : 0
  source                                        = "../modules/prometheus"
  k8s_cluster_name                              =  local.k8s_cluster_name
  k8s_namespace                                 =  var.k8s_observability_namespace
  environment                                   =  var.environment
  prometheus_chart_version                      =  var.prometheus_chart_version
  grafana_ingress_hostname                      =  "grafana.${var.public_domain_name}"

  depends_on = [module.external-dns, module.lets-encrypt]
}



module "external-secrets-controller" {
  count = var.include_external_secrets_module ? 1 : 0
  source                        = "../modules/external-secrets-controller"
  k8s_cluster_name              =  local.k8s_cluster_name
  external_secret_chart_version =  var.external_secret_chart_version
 

 # depends_on = [module.cert-manager]
}


module "kube-cost" {
 
  source                    = "../modules/kube-cost"
  k8s_cluster_name          =  local.k8s_cluster_name
  kubecost_chart_version    =  var.kubecost_chart_version
  environment               =  var.environment
  ingress_host              =  "kubecost.${var.public_domain_name}"

  depends_on = [module.lets-encrypt, module.external-dns, module.prometheus]
}


 
 # Add the loki-promtail module
module "loki-promtail" {
  count = var.include_loki_promtail_module ? 1 : 0

  source = "../modules/loki-promtail"
  k8s_cluster_name = local.k8s_cluster_name
  environment = var.environment
  
  # Optional: customize these values as needed
  # loki_chart_version = "6.32.0"
  # promtail_chart_version = "6.17.0"
  # storage_class_name = "gp3"
  # loki_storage_size = "10Gi"
  depends_on = [module.prometheus]
}
 