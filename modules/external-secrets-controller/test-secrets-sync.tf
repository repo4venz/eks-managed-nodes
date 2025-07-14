/*resource "null_resource" "create_namespaces" {
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
  name: ${var.aws_sm_secrets[count.index].k8s_secret_store_name}
  namespace:  ${var.aws_test_secrets[count.index].application_namespace}
spec:
  provider:
    aws:
      service: SecretsManager
      region: ${data.aws_region.current.id}
      auth:
        jwt:
          serviceAccountRef:
            name: "${var.service_account_name}-${count.index}"
YAML

depends_on = [   
                helm_release.external_secrets , 
                kubernetes_service_account.this, 
                time_sleep.wait_60_seconds_for_external_secret_controller  
                ]
}

 
/*
 
# We will now create our ExternalSecret resource, specifying the secret we want to access and referencing the previously created SecretStore object. 
# We will specify the existing AWS Secrets Manager secret name and keys.


resource "time_sleep" "wait_30_seconds_for_secret_store" {
  create_duration = "30s"
  depends_on = [kubectl_manifest.kubernetes-secret-store]
}
 
 
resource "kubectl_manifest" "kubernetes-external-secret" {
    wait = true
    yaml_body = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: "${var.k8s_cluster_name}-external-secret"
  namespace:  ${var.app_namespace}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: "${var.k8s_cluster_name}-common-secret-store"
    kind: SecretStore
  target:
    name:  "application-credentials"
    creationPolicy: Owner
  data:
  - secretKey:  "application-username"
    remoteRef:
      key: "test/application/credentials" #AWS Secrets Manager secret name
      property:  "app-username" #AWS Secrets Manager secret key
  - secretKey: "application-password"
    remoteRef:
      key: "test/application/credentials" #AWS Secrets Manager secret name
      property: "app-password" #AWS Secrets Manager secret key
YAML

depends_on = [ kubectl_manifest.kubernetes-secret-store , time_sleep.wait_30_seconds_for_secret_store  ]

}

 */