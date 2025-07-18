resource "helm_release" "aws_efs_csi_driver" {
  name       = "aws-efs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  version    = var.efs_csi_helm_chart_version #"2.4.0"
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [yamlencode({
    controller = {
      serviceAccount = {
        create = true
        name   = "efs-csi-controller-sa"
        annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.efs_csi_driver_role.arn
        }
    }
  }
})]
  depends_on = [
    aws_iam_role_policy_attachment.efs_csi_driver_policy_attach,
    aws_iam_role.efs_csi_driver_role
  ]
}


 