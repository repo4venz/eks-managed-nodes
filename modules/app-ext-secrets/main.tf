 
resource "null_resource" "create_namespaces" {
  #for_each = { for idx, secret in var.aws_test_secrets : idx => secret.application_namespace }
  for_each = toset(var.app_namespace)

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

 
# Create SecretStores in each application namespace
resource "kubernetes_manifest" "secret_store" {
  #for_each = { for idx, secret in var.aws_test_secrets : idx => secret.application_namespace }
  for_each = toset(var.app_namespace)

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "SecretStore"
    metadata = {
      name      = "aws-secrets-store-${each.value}"
      namespace = each.key
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = data.aws_region.current.id
          auth = {
            jwt = {
              serviceAccountRef = {
                name = "${each.value}-eso-sa"
              }
            }
          }
        }
      }
    }
  }
    depends_on = [ aws_iam_role_policy_attachment.eso_app_irsa_attachment    ]
}
