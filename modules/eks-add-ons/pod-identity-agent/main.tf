
  /*name       = "aws-pod-identity-agent"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-pod-identity-agent"
  #version    = "aws_eks_addon_version.pod_identity_agent.version"
  namespace  = "kube-system"

  values = [
    yamlencode({
      serviceAccount = {
        create = false
        annotations = {
          "eks.amazonaws.com/role-arn" = var.eks_worker_nodes_role_arn
        }
      }
      region = data.aws_region.current.id
      clusterName = var.k8s_cluster_name
      })
    ]
}
*/

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name                = data.aws_eks_cluster.this.name
  addon_name                  = data.aws_eks_addon_version.pod_identity_agent.addon_name
  addon_version               = data.aws_eks_addon_version.pod_identity_agent.version # optional (e.g. "v1.16.0-eksbuild.1")
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}