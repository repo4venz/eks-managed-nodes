resource "null_resource" "create_namespaces" {
  for_each = { for idx, secret in var.aws_test_secrets : idx => secret.application_namespace }

  provisioner "local-exec" {
    command = <<EOT
      if ! kubectl get namespace ${each.value} >/dev/null 2>&1; then
        kubectl create namespace ${each.value}
        echo "Created namespace: ${each.value}"
      else
        echo "Namespace ${each.value} already exists"
      fi
    EOT
  }
}


resource "time_sleep" "wait_60_seconds_for_external_secret_controller" {
  create_duration = "60s"
  depends_on = [helm_release.external_secrets]
}

# Creating Kubernetes SecretStore in the cluster so that Secrets can synchronise from AWS Secrets Manager
# Once Secrets are synchronised Pods can use the secrets within the cluster

resource "kubectl_manifest" "kubernetes-secret-store" {
    count = length(var.aws_test_secrets) 

    wait = true
    yaml_body = <<YAML
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: ${var.aws_test_secrets[count.index].k8s_secret_store_name}
  namespace:  ${var.aws_test_secrets[count.index].application_namespace}
spec:
  provider:
    aws:
      service: SecretsManager
      region: ${data.aws_region.current.id}
      auth:
        jwt:
          serviceAccountRef:
            name: ${var.service_account_name}
YAML

depends_on = [   
                helm_release.external_secrets,
                time_sleep.wait_60_seconds_for_external_secret_controller  
                ]
}