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

data "aws_eks_addon_version" "efs_csi" {
  addon_name   = "aws-efs-csi-driver"
  kubernetes_version = aws_eks_cluster.demo_eks_cluster.version
}

data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.demo_eks_cluster.name
}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = aws_eks_cluster.demo_eks_cluster.name
}

/*
 data "aws_ssm_parameter" "eks_optimized_ami" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.demo_eks_cluster.version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}
*/