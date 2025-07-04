resource "aws_iam_policy" "cluster_autoscaler" {
  name = substr("${var.k8s_cluster_name}-EKSClusterAutoscalerPolicy",0,64)
  path        = "/"
  description = "Policy for EKS Cluster Autoscaler"

  policy = file("${path.module}/cluster-autoscaler-policy.json")
}

 
resource "aws_iam_role" "cluster_autoscaler" {
  name = substr("${var.k8s_cluster_name}-ClusterAutoscalerRole",0,64)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.this.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" = "system:serviceaccount:${var.k8s_namespace}:cluster-autoscaler"
          }
        }
      }
    ]
  })
}
  


resource "aws_iam_role_policy_attachment" "cluster_autoscaler_attach" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = var.k8s_namespace
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  #version    = " 9.46.6" # Use latest compatible version
  create_namespace = false
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

 values = [
    yamlencode({
      autoDiscovery = {
        clusterName = var.k8s_cluster_name
      }
      awsRegion      = data.aws_region.current.id
      cloudProvider  = "aws"
      rbac = {
        create = true
        serviceAccount = {
          name = "cluster-autoscaler"
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
          }
        }
      }
      extraArgs = {
      skip-nodes-with-local-storage = "false"
      expander                      = "least-waste"
      }
    })
  ]

  depends_on = [aws_iam_role_policy_attachment.cluster_autoscaler_attach,
  aws_iam_role.cluster_autoscaler ]
}
 



