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

# Configure the Kubernetes authentication method in Vault
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "example" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = data.kubernetes_secret_v1.vault_secret.data["ca.crt"]
  token_reviewer_jwt = data.kubernetes_secret_v1.vault_secret.data["token"]
}

# Create a role for Kubernetes authentication
resource "vault_kubernetes_auth_backend_role" "external-secrets" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "external-secrets"
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = ["external-secrets"]
  token_policies                   = ["readonly"]
  audience                         = "https://kubernetes.default.svc.cluster.local"
}

# Create a role for Kubernetes authentication
resource "vault_kubernetes_auth_backend_role" "debug" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "debug"
  bound_service_account_names      = ["debug"]
  bound_service_account_namespaces = ["default"]
  token_policies                   = ["readonly"]
  audience                         = "https://kubernetes.default.svc.cluster.local"
}