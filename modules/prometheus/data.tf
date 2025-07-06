
data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster_auth" "iam_authenticator" {
  name = var.k8s_cluster_name   
}

data "aws_eks_cluster" "eks" {
  name = var.k8s_cluster_name  
}


data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

