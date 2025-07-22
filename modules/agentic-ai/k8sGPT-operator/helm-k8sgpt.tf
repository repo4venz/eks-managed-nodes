resource "helm_release" "k8sgpt" {
  name             = "k8sgpt-operator"
  repository       = "https://charts.k8sgpt.ai"
  chart            = "k8sgpt-operator"
  namespace        = var.k8sgpt_namespace
  version          = var.k8sgpt_helm_version
  create_namespace = true

  values = [
    templatefile("${path.module}/values-k8sgpt.yaml", {
      pod_identity_role_arn = aws_iam_role.pod_identity_role_k8sgpt.arn
    })
  ]

  set {
    name  = "k8sgpt-operator.ai.enabled"
    value = "true"
  }

  set {
    name  = "k8sgpt-operator.ai.backend"
    value = "bedrock"
  }

  depends_on = [
    aws_iam_role.pod_identity_role_k8sgpt,
    aws_iam_role_policy_attachment.pod_policy_k8sgpt_attach
  ]
}
