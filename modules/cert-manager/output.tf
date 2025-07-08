

# -------------------
# OUTPUTS
# -------------------
 

output "cert_manager_namespace" {
  value       = kubernetes_namespace.cert_manager.metadata[0].name
  description = "Namespace where cert-manager is installed."
}

output "cert_manager_release_name" {
  value       = helm_release.cert_manager.name
  description = "Helm release name of cert-manager."
}


/*

output "letsencrypt_issuer" {
  value       = kubernetes_manifest.letsencrypt_clusterissuer[0].manifest["metadata"]["name"]
  description = "Name of the Let's Encrypt ClusterIssuer."
}
*/