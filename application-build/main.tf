
 

module "kubernetes_app" {
    count = var.include_k8s_app_module ? 1 : 0
    source                      =  "../modules/kubernetes-app"
    app_namespace               =  var.app_namespace[0]
    ingress_hostname            =  "game.${var.public_domain_name}"

  #depends_on = [module.cert-manager]
}

module "kubernetes_app_secured" {
    count = var.include_k8s_app_secured_module ? 1 : 0
    source                      =  "../modules/kubernetes-app-secured"
    app_namespace               =  var.app_namespace[1]
    environment                 =  var.environment
    ingress_hostname            =  "game-secured.${var.public_domain_name}"

  #depends_on = [module.lets-encrypt]
  
}
 

 module "application-external-secrets" {
  count = var.application-external-secrets_module ? 1 : 0
  source                        = "../modules/app-ext-secrets"
  app_namespace                 =  var.app_namespace   

 # depends_on = [module.cert-manager]
}
