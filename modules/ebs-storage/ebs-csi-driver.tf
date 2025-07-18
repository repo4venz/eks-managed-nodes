  resource "helm_release" "aws_ebs_csi_driver" {
    name       = "aws-ebs-csi-driver"
    namespace  = "kube-system"
    repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
    chart      = "aws-ebs-csi-driver"
    version    =  var.ebs_csi_helm_chart_version
    atomic           = true
    cleanup_on_fail  = true
    timeout    = 900

   values = [
    yamlencode({
      controller = {
        serviceAccount = {
          create = true
          name   = var.ebs_csi_service_account_name
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_driver_role.arn
          }
        }
      }
      node = {
        serviceAccount = {
          create = true
          name   = "ebs-csi-node-sa"
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_driver_role.arn
          }
        }
      }
    })
  ]
    depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_driver_policy_attach,
    aws_iam_role_policy_attachment.ebs_csi_driver_policy
  ]
  }

