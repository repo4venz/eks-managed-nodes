data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "this" {
  name = var.k8s_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.k8s_cluster_name
}


data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}


data "aws_iam_policy_document" "kube_cost_assume" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.oidc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kubecost:kubecost-cost-analyzer"]
    }
  }
}
 