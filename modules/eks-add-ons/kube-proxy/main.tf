resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.my_cluster.name
  addon_name        = "kube-proxy"
  addon_version     = data.aws_eks_addon_version.kube_proxy.version # Update to match your EKS version

  resolve_conflicts_on_create = "OVERWRITE"  # Optional: Handle conflicts automatically
  resolve_conflicts_on_update = "OVERWRITE"
}