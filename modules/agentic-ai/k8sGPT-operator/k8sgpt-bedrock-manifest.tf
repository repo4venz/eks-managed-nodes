/*

resource "time_sleep" "wait_120_seconds" {
  create_duration = "120s"  # 2 minutes

  depends_on = [
    aws_eks_pod_identity_association.k8sgpt_association,
    helm_release.k8sgpt
  ]
}


#kubectl patch k8sgpt bedrock -n k8sgpt-operator-system -p '{"metadata":{"finalizers":[]}}' --type=merge
# -------------------

resource "null_resource" "create_namespace_if_not_exists" {
 
  provisioner "local-exec" {
    command = <<EOT
      if ! kubectl get namespace ${var.app_namespace} >/dev/null 2>&1; then
        kubectl create namespace ${var.app_namespace}
        echo "Created namespace: ${var.app_namespace}"
      else
        echo "Namespace ${var.app_namespace} already exists"
      fi
    EOT
  }
    triggers = {
    always_run = timestamp() # Forces re-run on every `apply`; can be improved
  }
}


resource "kubernetes_manifest" "k8sgpt_bedrock" {
  manifest = {
    apiVersion = "core.k8sgpt.ai/v1alpha1"
    kind       = "K8sGPT"
    metadata = {
      name      = var.ai_foundation_model_service
      namespace = var.k8sgpt_namespace
    }
    spec = {
      ai = {
        enabled  = true
        model    = var.ai_foundation_model_name
        region   = var.ai_foundation_model_region
        backend  = "amazonbedrock"
        language = "english"
      }
      noCache    = false
      explain      = true
      anonymize    = true
      maxConcurrency = 5
      includeFilters = ["Security", "Networking", "Pods", "Nodes", "Services", "Deployments", "StatefulSets"]
      excludeFilters = ["Helm"]
      repository = "ghcr.io/k8sgpt-ai/k8sgpt"
      version    = "v0.4.12"
    }
  }
 depends_on = [
    aws_eks_pod_identity_association.k8sgpt_association,
    helm_release.k8sgpt
  ]
}

*/
