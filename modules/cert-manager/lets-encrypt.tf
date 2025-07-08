

resource "null_resource" "wait_for_cert_manager_crds" {
  provisioner "local-exec" {
    command = <<EOT
      for i in $(seq 1 10); do
        kubectl get crd clusterissuers.cert-manager.io && exit 0
        echo "Waiting for cert-manager CRDs to be ready..."
        sleep 6
      done
      echo "CRD not found" >&2
      exit 1
    EOT
  }

  depends_on = [helm_release.cert_manager]
}



# -------------------
# LET'S ENCRYPT CLUSTERISSUER
# -------------------
resource "kubernetes_manifest" "letsencrypt_clusterissuer" {
  count = var.enable_lets_encrypt_ca ? 1 : 0
  
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name   = "letsencrypt-${var.environment}"  #prod: "letsencrypt-prod"
    }
    spec = {
      acme = {
        server =  "${local.lets_encrypt_server_url}"
        email  = var.email
        privateKeySecretRef = {
          name = "letsencrypt-${var.environment}" 
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }
  depends_on = [
    helm_release.cert_manager,
    null_resource.wait_for_cert_manager_crds
  ]
}




        /*solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]*/
/*
        solvers = [
          {
            dns01 = {
              route53 = {
              region     = data.aws_region.current.id
              hostedZoneID = var.route53_zone_id
              }
            }
          }
        ]

        */