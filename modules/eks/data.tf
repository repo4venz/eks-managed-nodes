data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

 
data "http" "eks_cluster_readiness" {

  url            = join("/", [module.eks.eks_cluster_endpoint, "healthz"]) #refering output variable values
  ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority_data) #refering output variable values
  timeout        = var.eks_readiness_timeout
}

 

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}