/*
resource "null_resource" "create_namespace_if_not_exists" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl get namespace ${var.namespace} || kubectl create namespace ${var.namespace}
    EOT
  }

  triggers = {
    always_run = timestamp() # Forces re-run on every `apply`; can be improved
  }
}
*/



# Terraform module to deploy cert-manager to EKS using Helm
resource "aws_iam_role" "cert_manager_role" {
  name = "${var.k8s_cluster_name}-cert-manager-irsa-role"
  description = "IAM Role for Cert Manager for Staging on DNS01 for Route53"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_assume_role_policy.json
}


resource "aws_iam_policy" "cert_manager_policy_dns01" {
  name   = substr("${var.k8s_cluster_name}-cert-manager-dns1-policy",0,64)
  description = "IAM policy for Cert Manager for Staging on DNS01 for Route53"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action =  [
          "route53:GetChange",
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets",
          "route53:ListHostedZones"
			],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cert_manager_attach" {
  role       = aws_iam_role.cert_manager_role.name
  policy_arn = aws_iam_policy.cert_manager_policy_dns01.arn
}

 

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = var.namespace
  version    = var.certmanager_chart_version
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [
    yamlencode({
      installCRDs = var.install_crds
      serviceAccount = {
        create = true
        name   = "cert-manager"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.cert_manager_role.arn
        }
      }
    })
  ]
  depends_on = [
  aws_iam_role_policy_attachment.cert_manager_attach,
  aws_iam_role.cert_manager_role  #,
  #null_resource.create_namespace_if_not_exists
  ]
}
 