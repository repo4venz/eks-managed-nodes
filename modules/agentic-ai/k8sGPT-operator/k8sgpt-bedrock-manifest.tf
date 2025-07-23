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


/*
cat > k8sgpt-bedrock.yaml<<EOF
apiVersion: core.k8sgpt.ai/v1alpha1
kind: K8sGPT
metadata:
  name: bedrock
  namespace: k8sgpt-operator-system
spec:
  ai:
    enabled: true
    model: anthropic.claude-3-5-sonnet-20240620-v1:0 
    region: eu-central-1
    backend: amazonbedrock
    language: english
  noCache: false
  repository: ghcr.io/k8sgpt-ai/k8sgpt
  version: v0.4.12
EOF

kubectl apply -f k8sgpt-bedrock.yaml

*/


resource "null_resource" "k8sgpt_create" {

  provisioner "local-exec" {
    when    = create
    command = <<EOT
    cat <<EOF | kubectl apply -f -
    apiVersion = "core.k8sgpt.ai/v1alpha1"
    kind       = "K8sGPT"
    metadata = {
      name      = "${var.ai_foundation_model_service}"
      namespace = "${var.k8sgpt_namespace}"
    }
    spec = {
      ai = {
        enabled  = true
        model    = "${var.ai_foundation_model_name}"
        region   = "${var.ai_foundation_model_region}"
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
      EOF
    EOT
  }

  triggers = {
    always_run = timestamp() # Forces re-run on every `apply`; can be improved
  }
  # Ensure this runs after the Helm release and pod identity association
   depends_on = [
    aws_eks_pod_identity_association.k8sgpt_association,
    helm_release.k8sgpt
  ]
}


resource "null_resource" "k8sgpt_cleanup" {
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
    kubectl patch k8sgpt ${var.ai_foundation_model_service} -n ${var.k8sgpt_namespace} -p '{\"metadata\":{\"finalizers\":[]}}' --type=merge --ignore-not-found 
    kubectl delete k8sgpt ${var.ai_foundation_model_service} -n ${var.k8sgpt_namespace} --ignore-not-found
  EOT
  }

  triggers = {
    always_run = timestamp()
  }
}