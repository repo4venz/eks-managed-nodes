resource "aws_iam_policy" "cluster_autoscaler" {
  name = substr("${var.cluster_name}-${var.environment}-EKSClusterAutoscalerPolicy",0,64)
  path        = "/"
  description = "Policy for EKS Cluster Autoscaler"

  policy = file("${path.module}/cluster-autoscaler-policy.json")
}

resource "aws_iam_role" "cluster_autoscaler" {
 name = substr("${var.cluster_name}-${var.environment}-ClusterAutoscalerRole",0,64)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "cluster_autoscaler_attach" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = " 9.46.6" # Use latest compatible version

  set = {
    "autoDiscovery.clusterName"                                 = data.aws_eks_cluster.cluster.name
    "awsRegion"                                                 = data.aws_region.current.id
    "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
    "rbac.create"                                               = "true"
    "cloudProvider"                                             = "aws"
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_autoscaler_attach]
}


