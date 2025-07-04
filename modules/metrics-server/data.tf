data "aws_eks_cluster" "this" {
  name = var.k8s_cluster_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}