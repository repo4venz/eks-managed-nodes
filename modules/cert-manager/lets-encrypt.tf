# -------------------
# LET'S ENCRYPT CLUSTERISSUER
# -------------------
resource "kubernetes_manifest" "letsencrypt_clusterissuer" {
  #count = var.enable_lets_encrypt_ca ? 1 : 0
  
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name =  "letsencrypt-staging"    #prod: "letsencrypt-prod"
    }
    spec = {
      acme = {
        server =  "https://acme-staging-v02.api.letsencrypt.org/directory"            # prod url: "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.email
        privateKeySecretRef = {
          name = "letsencrypt-staging"     #"letsencrypt-prod"
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
        solvers = [
          {
            dns01 = {
              route53 = {
              region     = data.region.current.id
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
