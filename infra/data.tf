data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

 data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = module.eks.eks_cluster_name
}
/*
data "aws_eks_cluster" "this" {
  name =  module.eks.eks_cluster_name  #"${var.cluster_name}-${var.environment}" # Replace with your cluster name
}
*/
