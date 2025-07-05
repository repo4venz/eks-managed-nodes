data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}


data "aws_eks_addon_version" "ebs_csi" {
  addon_name   = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.demo_eks_cluster.version
}
 