/*
The nvidia-device-plugin in Kubernetes is a DaemonSet provided by NVIDIA that enables GPU scheduling and management in your Kubernetes cluster.

What it does:
- When installed, the NVIDIA device plugin:
- Detects NVIDIA GPUs on each node.
- Registers GPU resources (nvidia.com/gpu) with the kubelet.
- Allows Kubernetes to schedule pods requesting GPU resources.
- Handles GPU resource allocation per container (e.g., 1 GPU per pod).
- Ensures proper isolation and device access within containers.

How it works:
- The plugin runs as a DaemonSet: it runs on every node with a GPU.
- It communicates with the kubelet using the Kubernetes Device Plugin API.
- It does not install GPU drivers — you must install NVIDIA drivers separately on each GPU node.
*/

resource "helm_release" "nvidia_device_plugin" {

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
        name   = var.nvidia_service_account_name
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
