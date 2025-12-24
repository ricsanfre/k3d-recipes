data "kubernetes_secret_v1" "vault_secret" {
  metadata {
    name      = "vault-auth-token"
    namespace = "vault"
  }
}


output "vault_secret" {
  value     = data.kubernetes_secret_v1.vault_secret.data
  sensitive = true
}