resource "helm_release" "k8sgpt" {
  name             = "k8sgpt-operator"
  repository       = "https://charts.k8sgpt.ai"
  chart            = "k8sgpt-operator"
  namespace        = var.k8sgpt_namespace
  version          = var.k8sgpt_helm_version
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [
    data.template_file.k8sgpt_values.rendered
  ]

  depends_on = [
    aws_iam_role_policy_attachment.pod_policy_k8sgpt_attach
  ]
}


data "template_file" "k8sgpt_values" {
  template = file("${path.module}/k8sgpt-values.yaml")
  
  vars = {
    ai_foundation_model_service = var.ai_foundation_model_service
    ai_foundation_model_name = var.ai_foundation_model_name   
    ai_foundation_model_region = var.ai_foundation_model_region
    k8sgpt_pod_identity_role_arn = aws_iam_role.pod_identity_role_k8sgpt.arn
    prometheus_namespace = var.prometheus_namespace
  }
}
