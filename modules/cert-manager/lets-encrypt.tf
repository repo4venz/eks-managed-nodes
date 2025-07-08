# -------------------
# LET'S ENCRYPT CLUSTERISSUER
# -------------------
resource "kubernetes_manifest" "letsencrypt_clusterissuer" {
  #count = var.enable_lets_encrypt_ca ? 1 : 0
  
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name   = "letsencrypt-${var.environment}"  #prod: "letsencrypt-prod"
    }
    spec = {
      acme = {
        server =  "${var.lets_encrypt_server_url}"
        email  = var.email
        privateKeySecretRef = {
          name = "letsencrypt-${var.environment}" 
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
    helm_release.cert_manager
  ]
}


/*

        /*solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]*/

        