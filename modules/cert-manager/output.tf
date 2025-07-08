

# -------------------
# OUTPUTS
# -------------------
 

output "cert_manager_namespace" {
  value       = var.namespace
  description = "Namespace where cert-manager is installed."
}

output "cert_manager_release_name" {
  value       = helm_release.cert_manager.name
  description = "Helm release name of cert-manager."
}



/*
output "letsencrypt_issuer" {
  value       = try(kubernetes_manifest.letsencrypt_clusterissuer[0].manifest["metadata"]["name"], "")
  description = "Name of the Let's Encrypt ClusterIssuer."
}
*/