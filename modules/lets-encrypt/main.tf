

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
 
}



# -------------------
# LET'S ENCRYPT CLUSTERISSUER
# -------------------


#### Using NGINX Ingress and Route53 DNS ########

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
            // DNS-01 (for wildcard or DNS-based challenges)
            dns01 = {
              route53 = {
              region     = data.aws_region.current.id
              hostedZoneID = var.route53_zone_id
              }
            }
          },
          // HTTP-01 (for basic domains via Ingress)
          {
            http01 = {
              ingress = {
                class = "nginx"
                pathType = "Prefix"
              }
            }
          }
        ]
      }
    }
  }
  depends_on = [
    null_resource.wait_for_cert_manager_crds
  ]
}




#### Using Route53 DNS ########
/*
resource "kubernetes_manifest" "letsencrypt_clusterissuer_dns01" {
  count = var.enable_lets_encrypt_ca ? 1 : 0
  
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name   = "letsencrypt-${var.environment}-dns"  #prod: "letsencrypt-prod"
    }
    spec = {
      acme = {
        server =  "${local.lets_encrypt_server_url}"
        email  = var.email
        privateKeySecretRef = {
          name = "letsencrypt-${var.environment}-dns" 
        }
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
      }
    }
  }
  depends_on = [
    null_resource.wait_for_cert_manager_crds
  ]
}
*/
 