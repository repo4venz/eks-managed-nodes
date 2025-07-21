resource "helm_release" "nvidia_device_plugin" {
  count = var.install_nvidia_device_plugin ? 1 : 0

  name       = "nvidia-device-plugin"
  repository = "https://nvidia.github.io/k8s-device-plugin"
  chart      = "nvidia-device-plugin"
  version    = var.nvidia_device_plugin_helm_version
  namespace  = var.nvidia_plugin_namespace
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
          "eks.amazonaws.com/role-arn" = aws_eks_pod_identity_association.nvidia_device_plugin_association[0].arn
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
