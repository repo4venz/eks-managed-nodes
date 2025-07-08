# -------------------
# LET'S ENCRYPT CLUSTERISSUER
# -------------------
resource "kubernetes_manifest" "letsencrypt_clusterissuer" {
  for_each = var.enable_lets_encrypt_ca ? { "default" = true } : {}
  
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.email
        privateKeySecretRef = {
          name = "letsencrypt-prod"
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
    helm_release.cert_manager
  ]
}
