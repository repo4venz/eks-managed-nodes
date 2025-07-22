resource "time_sleep" "wait_120_seconds" {
  create_duration = "120s"  # 2 minutes

  depends_on = [
    aws_eks_pod_identity_association.k8sgpt_association,
    helm_release.k8sgpt
  ]
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
    aws_eks_pod_identity_association.k8sgpt_association
  ]
}

 
