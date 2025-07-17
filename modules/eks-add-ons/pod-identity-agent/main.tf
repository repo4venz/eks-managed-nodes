 

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name                = data.aws_eks_cluster.this.name
  addon_name                  = data.aws_eks_addon_version.pod_identity_agent.addon_name #"aws-eks-pod-identity-agent"
  addon_version               = data.aws_eks_addon_version.pod_identity_agent.version # optional (e.g. "v1.16.0-eksbuild.1")
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}