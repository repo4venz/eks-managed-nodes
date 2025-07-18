 
resource "null_resource" "create_namespaces_if_not_exists" {
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
    triggers = {
    always_run = timestamp() # Forces re-run on every `apply`; can be improved
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
      name      = "aws-secrets-common-store-${each.value}"
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
    depends_on = [ aws_iam_role_policy_attachment.eso_app_irsa_attachment,
    null_resource.create_namespaces_if_not_exists    ]
}


 
 
# We will now create our ExternalSecret resource, specifying the secret we want to access and referencing the previously created SecretStore object. 
# We will specify the existing AWS Secrets Manager secret name and keys.


resource "time_sleep" "wait_30_seconds_for_secret_store" {
  create_duration = "30s"
  depends_on = [kubernetes_manifest.secret_store]
}
 
 resource "kubernetes_manifest" "external_secret_synced_secretstore" {
  for_each = { for idx, secret in var.aws_test_secrets : idx => secret }

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "${var.k8s_cluster_name}-external-secret-${each.key}"
      namespace = "${each.value.application_namespace}"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secrets-common-store-${each.value.application_namespace}"
        kind = "SecretStore"
      }
      target = {
        name           = "application-credentials"
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "application-username"  # Key in the K8s Secret
          remoteRef = {
            key      = "${each.value.secret_name}"   # Name of the secret in AWS Secrets Manager
            property = "app-username"   # Specific field in the AWS secret
          }
        },
        {
          secretKey = "application-password"        # Key in the K8s Secret
          remoteRef = {
            key      = "${each.value.secret_name}"   # Same AWS secret as above
            property = "app-password"                   # Different field in the same AWS secret
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.secret_store,
    time_sleep.wait_30_seconds_for_secret_store
  ]
}

/*
aws_test_secrets               = [
                                    {
                                        secret_name = "test/application3/credentials",          # Reference to the secret of AWS Secret Manager 
                                        application_namespace = "myapps1"                # K8s namespace in EKS where the AWS Secret will sync
                                    },
                                    {
                                        secret_name = "test/application4/credentials",
                                        application_namespace = "myapps2"
                                    }
                                ]

                                */