locals{
  lets_encrypt_server_url = var.acme_environment == "prod" ? "https://acme-v02.api.letsencrypt.org/directory"  : "https://acme-staging-v02.api.letsencrypt.org/directory"
}
