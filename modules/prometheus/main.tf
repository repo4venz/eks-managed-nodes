

resource "helm_release" "prometheus" {
  name       = "kube-prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.k8s_namespace
  version    = var.prometheus_chart_version
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 300

  values = [
    data.template_file.prometheus_values.rendered
  ]

  depends_on = [
    aws_iam_role_policy_attachment.prometheus_policy_attachment,
    aws_iam_role_policy_attachment.prometheus_policy_custom
  ]
}



data "template_file" "prometheus_values" {
  template = file("${path.module}/prometheus-values.yaml")
  
  vars = {
    service_account_name = var.prometheus_service_account_name
    prometheus_role_arn  = aws_iam_role.prometheus_role.arn
    storage_class_name = var.efs_storage_class_name #var.ebs_storage_class_name
    grafana_ingress_hostname = var.grafana_ingress_hostname
    environment = var.environment
    storage_size = var.storage_size
    prometheus_retention = var.prometheus_retention
    k8s_namespace = var.k8s_namespace
  }
}
 