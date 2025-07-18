data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.k8s_cluster_name
}

 
