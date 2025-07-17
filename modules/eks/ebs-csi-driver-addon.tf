
data "aws_iam_policy_document" "ebs_csi_assume_role_policy" {
  count = var.include_ebs_csi_driver_addon ? 1 : 0

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
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}
  
 

resource "aws_iam_role" "ebs_csi_driver_role" {
  count = var.include_ebs_csi_driver_addon ? 1 : 0

  name = substr("${data.aws_eks_cluster.this.name}-ebs-csi-driver-role", 0, 64)
  description = "IAM Role for EBS CSI Driver to create EBS volumes for EC2"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role_policy[0].json
}

 
# 1. Required IAM policy (EBS CSI needs this for the node group role)
resource "aws_iam_role_policy_attachment" "ebs_csi_iam_policy" {
  count = var.include_ebs_csi_driver_addon ? 1 : 0
 
  role       = aws_iam_role.ebs_csi_driver_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
   

# 2. Enable the EBS CSI Driver as an EKS add-on
resource "aws_eks_addon" "ebs_csi" {
  count = var.include_ebs_csi_driver_addon ? 1 : 0

  cluster_name = aws_eks_cluster.demo_eks_cluster.name
  addon_name   = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs_csi.version  # Use `latest` or lookup via data source
  service_account_role_arn = var.include_ebs_csi_driver_addon ? aws_iam_role.ebs_csi_driver_role[0].arn : null

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
      defaultStorageClass = {
        enabled = true
            name = var.ebs_volume_custom_name  # Custom name
            annotations = {
            "kubernetes.io/created-for/pv/storagetype" = "EBS"
            "kubernetes.io/created-for/pv/driver" = "ebs.csi" 
            "kubernetes.io/created-for/pv/volume-type" = "gp3"
            "kubernetes.io/created-for/pv/iops" = var.ebs_volume_iops
            "kubernetes.io/created-for/pv/encrypted" = "true"
            "kubernetes.io/created-for/pv/kms-key-id" = var.eks_kms_secret_encryption_key_arn 
          }
        parameters = {
          type = "gp3"  # Example volume type
          iops = var.ebs_volume_iops  # Example IOPS value
          throughput = var.ebs_volume_throughput  # Example throughput value
          encrypted = "true"
          kmsKeyId = var.eks_kms_secret_encryption_key_arn  # Example KMS Key ARN}
        }
      }
    })

    tags = {
      Name = "EBS CSI Driver Addon"
      Desc = "EBS CSI Driver Addon for EKS Worker Nodes"
  }
  depends_on = [
    aws_eks_node_group.demo_eks_nodegroup_spot,
    aws_eks_node_group.demo_eks_nodegroup_ondemand,
    aws_iam_role_policy_attachment.ebs_csi_iam_policy,
    aws_iam_role.ebs_csi_driver_role
  ]
}



