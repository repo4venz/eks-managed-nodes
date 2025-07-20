resource "helm_release" "nvidia_device_plugin" {
  name       = "nvidia-device-plugin"
  repository = "https://nvidia.github.io/k8s-device-plugin"
  chart      = "nvidia-device-plugin"
  version    = var.nvvidia_device_plugin_version
  namespace  = var.namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  # Optional: configure tolerations or other values
  values = [
    yamlencode({
    serviceAccount = {
        create = true
        name   = "${var.nvidia_service_account_name}"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_eks_pod_identity_association.nvidia_device_plugin_association.arn
        }
      }
      tolerations = [
        {
          key      = "nvidia.com/gpu"
          operator = "Exists"
          effect   = "NoSchedule"
        },
        {
          operator = "Exists" # tolerates all
        }
      ]
    })
  ]

  # Make sure the cluster and node group are up before plugin is installed
  depends_on = [
    aws_eks_pod_identity_association.nvidia_device_plugin_association
  ] 
}
