data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

 
data "http" "eks_cluster_readiness" {

  url            = join("/", [data.aws_eks_cluster.demo_eks_cluster.endpoint, "healthz"])
  ca_certificate = base64decode(data.aws_eks_cluster.demo_eks_cluster.certificate_authority[0].data)
  timeout        = var.eks_readiness_timeout
}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}