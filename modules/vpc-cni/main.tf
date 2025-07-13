 
resource "aws_iam_role" "vpc_cni_irsa_role" {
  name  = substr("${var.k8s_cluster_name}-vpc-cni-irsa-role",0,64)
  description = "IAM Role for VPC CNI"
  assume_role_policy = data.aws_iam_policy_document.vpc_cni_assume.json
}

 
 
resource "aws_iam_role_policy_attachment" "vpc_cni_attach" {
  role       = aws_iam_role.vpc_cni_irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}



resource "aws_eks_addon" "vpc_cni" {

  cluster_name                = data.aws_eks_cluster.this.name
  addon_name                  = data.aws_eks_addon_version.vpc_cni.addon_name
  addon_version               = data.aws_eks_addon_version.vpc_cni.version # optional (e.g. "v1.16.0-eksbuild.1")
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  service_account_role_arn = aws_iam_role.vpc_cni_irsa_role.arn

  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_IP_TARGET           = "3"
      WARM_ENI_TARGET          = "1"
      WARM_PREFIX_TARGET       = "2"
    }
  })

  depends_on = [
    aws_iam_role_policy_attachment.vpc_cni_attach,
    aws_iam_role.vpc_cni_irsa_role
  ]
}
