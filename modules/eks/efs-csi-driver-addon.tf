data "aws_iam_policy_document" "efs_csi_assume_role_policy" {
  count = var.include_efs_csi_driver_addon ? 1 : 0

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
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "efs_csi_driver_role" {
  count = var.include_efs_csi_driver_addon ? 1 : 0

  name = substr("${data.aws_eks_cluster.eks_cluster_name}-efs-csi-driver-role",0,64) 
  assume_role_policy = data.aws_iam_policy_document.efs_csi_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "efs_csi_policy" {
  count = var.include_efs_csi_driver_addon ? 1 : 0

  role       = aws_iam_role.efs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}


resource "aws_eks_addon" "efs_csi_driver" {
  count = var.include_efs_csi_driver_addon ? 1 : 0
  
  cluster_name             = data.aws_eks_cluster.eks_cluster_name
  addon_name               = "aws-efs-csi-driver"
  addon_version = data.aws_eks_addon_version.efs_csi.version  # Use `latest` or lookup via data source
  service_account_role_arn = aws_iam_role.efs_csi_driver_role.arn
 
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

    tags = {
    Name = "EFS CSI Driver Addon"
  }

  depends_on = [
    aws_iam_role_policy_attachment.efs_csi_policy,
    aws_iam_role.efs_csi_driver_role,
    aws_eks_node_group.demo_eks_nodegroup
  ]
}

