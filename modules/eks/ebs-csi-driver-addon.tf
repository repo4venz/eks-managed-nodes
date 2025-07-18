/*
data "aws_iam_policy_document" "ebs_csi_assume_role_policy" {
  count = var.include_ebs_csi_driver ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:${var.ebs_csi_service_account_name}"]
    }
  }
}
  
 

resource "aws_iam_role" "ebs_csi_driver_role" {
  count = var.include_ebs_csi_driver ? 1 : 0

  name = substr("${data.aws_eks_cluster.this.name}-ebs-csi-driver-role", 0, 64)
  description = "IAM Role for EBS CSI Driver to create EBS volumes for EC2"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role_policy[0].json
}

 
# 1. Required IAM policy (EBS CSI needs this for the node group role)
resource "aws_iam_role_policy_attachment" "ebs_csi_iam_policy" {
  count = var.include_ebs_csi_driver ? 1 : 0
 
  role       = aws_iam_role.ebs_csi_driver_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_kms_usage_for_ebs_csi" {
  count = var.include_ebs_csi_driver ? 1 : 0
 
  role       = aws_iam_role.ebs_csi_driver_role[0].name
  policy_arn = aws_iam_policy.EKS_KMS_Usage_Policy.arn
}
*/
/*
### This is the EBS CSI Driver Addon for EKS
# It allows EKS to manage EBS volumes using the CSI driver
# This is the recommended way to use EBS volumes in EKS clusters. However, it cannot be customized as much as the manual installation.
# 2. Enable the EBS CSI Driver as an EKS add-on
resource "aws_eks_addon" "ebs_csi" {
  count = var.include_ebs_csi_driver ? 1 : 0

  cluster_name = aws_eks_cluster.demo_eks_cluster.name
  addon_name   = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs_csi.version  # Use `latest` or lookup via data source
  service_account_role_arn = var.include_ebs_csi_driver ? aws_iam_role.ebs_csi_driver_role[0].arn : null

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # Only supported configuration parameters
  configuration_values = jsonencode({
    storageClass = {
      defaultClass = true
      # Note: These are the only supported parameters in the EKS addon configuration
    }
  })

    tags = {
      "csi-driver-name" = "EBS CSI Driver Addon"
      "description" = "EBS CSI Driver Addon for EKS Worker Nodes"
      "terraform" = "true"
  }
  depends_on = [
    aws_eks_node_group.demo_eks_nodegroup_spot,
    aws_eks_node_group.demo_eks_nodegroup_ondemand,
    aws_iam_role_policy_attachment.ebs_csi_iam_policy,
    aws_iam_role.ebs_csi_driver_role
  ]
}
*/

/*
resource "helm_release" "aws_ebs_csi_driver" {
  count = var.include_ebs_csi_driver ? 1 : 0

  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  version    = var.ebs_csi_helm_chart_version
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 2000

  values = [
    yamlencode({
      controller = {
        serviceAccount = {
          create = true
          name   = var.ebs_csi_service_account_name
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_driver_role[0].arn
          }
        }
      }
      storageClasses = [
        {
          name = var.ebs_volume_type
          annotations = {
            "storageclass.kubernetes.io/is-default-class" = "true"
          }
          parameters = {
            iops      = var.ebs_volume_iops
            throughput = var.ebs_volume_throughput
            type      = var.ebs_volume_type
            encrypted = "true"
            kmsKeyId = var.eks_kms_secret_encryption_alias_arn
          }
        }
      ]
    })
  ]

   depends_on = [
    aws_eks_node_group.demo_eks_nodegroup_spot,
    aws_eks_node_group.demo_eks_nodegroup_ondemand,
    aws_eks_node_group.demo_eks_nodegroup_ondemand_high_pod,
    aws_eks_node_group.demo_eks_nodegroup_spot_high_pod,
    aws_iam_role_policy_attachment.ebs_csi_iam_policy,
    aws_iam_role.ebs_csi_driver_role
  ]
}

*/