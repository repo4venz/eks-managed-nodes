resource "helm_release" "pod_identity_agent" {
  name       = "aws-pod-identity-agent"
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

