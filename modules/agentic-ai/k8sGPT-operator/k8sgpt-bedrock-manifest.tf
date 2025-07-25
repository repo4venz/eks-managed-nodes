 
/*
resource "kubectl_manifest" "k8sgpt_create"  {
    yaml_body = <<YAML
apiVersion: core.k8sgpt.ai/v1alpha1
kind: K8sGPT
metadata:
  name: "${var.ai_foundation_model_service}"
  namespace: "${var.k8sgpt_namespace}"
spec:
  ai:
    enabled: true
    model: "${var.ai_foundation_model_name}" 
    region: "${var.ai_foundation_model_region}"
    backend: "amazonbedrock"
    language: "english"
  noCache: false
  repository: "ghcr.io/k8sgpt-ai/k8sgpt"
  version: "v0.4.12"
YAML
}



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



/*
resource "null_resource" "k8sgpt_create" {
  # This resource creates the K8sGPT instance using kubectl
  provisioner "local-exec" {
    command = <<EOT
cat <<EOF | kubectl apply -f -
apiVersion: core.k8sgpt.ai/v1alpha1
kind: K8sGPT
metadata:
  name: "${self.triggers.service_name}"
  namespace: "${self.triggers.namespace}"
spec:
  ai:
    enabled: true
    model: "${self.triggers.model_name}"
    region: "${self.triggers.region}"
    backend: "amazonbedrock"
    language: "english"
  noCache: false
  repository: "ghcr.io/k8sgpt-ai/k8sgpt"
  version: "v0.4.12"
EOF
EOT
  }

    triggers = {
    always_run = timestamp() # Forces re-run on every `apply`; can be improved
    # Store the values we need in triggers
    service_name  = var.ai_foundation_model_service
    namespace     = var.k8sgpt_namespace
    region        = var.ai_foundation_model_region
    model_name    = var.ai_foundation_model_name
    # Add any other values needed for cleanup
  }
  # Ensure this runs after the Helm release and pod identity association
   depends_on = [
    aws_eks_pod_identity_association.k8sgpt_association,
    helm_release.k8sgpt
  ]
}

 


resource "null_resource" "k8sgpt_cleanup" {

    triggers = {
    # Store the values we need in triggers
    service_name  = var.ai_foundation_model_service
    namespace     = var.k8sgpt_namespace
    # Add any other values needed for cleanup
    always_run = timestamp()
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT

      if ! kubectl get k8sgpt -n ${var.k8sgpt_namespace} >/dev/null 2>&1; then
        kubectl create namespace ${var.app_namespace}
        echo "Created namespace: ${var.app_namespace}"
      else
        echo "Namespace ${var.app_namespace} already exists"
      fi


    kubectl patch k8sgpt ${self.triggers.service_name} -n ${self.triggers.namespace} -p '{\"metadata\":{\"finalizers\":[]}}' --type=merge --ignore-not-found 
    kubectl delete k8sgpt ${self.triggers.service_name} -n ${self.triggers.namespace} --ignore-not-found
  EOT
  }
 
}

*/