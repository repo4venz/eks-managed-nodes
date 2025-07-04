 

provider "helm" {
  kubernetes {
    host                   = module.eks.eks_cluster_endpoint
    token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
    cluster_ca_certificate = module.eks.eks_cluster_certificate_authority_data
    #config_path = "./.kube/config"
    config_path ="/home/runner/.kube/config"
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}
