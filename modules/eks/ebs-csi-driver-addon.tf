# 1. Required IAM policy (EBS CSI needs this for the node group role)
resource "aws_iam_policy_attachment" "ebs_csi_iam_policy" {
  count = var.include_ebs_csi_driver_addon ? 1 : 0

  name       = substr("${aws_eks_cluster.demo_eks_cluster.name}-ebs-csi-driver-policy",0,64)  
  roles      = [aws_iam_role.eks_worker_nodes_role.name]  # adjust if needed
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# 2. Enable the EBS CSI Driver as an EKS add-on
resource "aws_eks_addon" "ebs_csi" {
  count = var.include_ebs_csi_driver_addon ? 1 : 0

  cluster_name = aws_eks_cluster.demo_eks_cluster.name
  addon_name   = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs_csi.version  # Use `latest` or lookup via data source

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn = null  # not needed for managed add-on
    tags = {
    Name = "EBS CSI Driver Addon"
  }
  depends_on = [
    aws_eks_node_group.demo_eks_nodegroup_spot
  ]
}
