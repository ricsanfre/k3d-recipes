# Vault kubernetes authentication 
# auth method accesses the Kubernetes TokenReview API to validate the provided JWT is still valid. 
# Service Accounts used in this auth method will need to have access to the TokenReview API. 
# If Kubernetes is configured to use RBAC roles, the Service Account should be granted permissions to access this API. 
# https://developer.hashicorp.com/vault/docs/auth/kubernetes#configuring-kubernetes 

resource "kubernetes_service_account_v1" "vault-auth-sa" {
  metadata {
    name = "vault-auth-sa"
    namespace = "default"
  }
}


resource "kubernetes_cluster_role_binding_v1" "vault-auth-crb" {
  metadata {
    name = "role-tokenreview-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.vault-auth-sa.metadata[0].name
    namespace = kubernetes_service_account_v1.vault-auth-sa.metadata[0].namespace
  }
}

# Long-lived token for vault-auth service account.
# From Kubernetes v1.24, secrets contained long-lived tokens associated to service accounts
# are not longer created.
# See how to create it in Kubernetes documentation:
# https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-a-long-lived-api-token-for-a-serviceaccount

resource "kubernetes_secret_v1" "vault-auth-token" {
  metadata {
    name = "vault-auth-token"
    namespace = "default"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.vault-auth-sa.metadata[0].name
    }
  }
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}


# Configure the Kubernetes authentication method in Vault
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "example" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = kubernetes_secret_v1.vault-auth-token.data["ca.crt"]
  token_reviewer_jwt = kubernetes_secret_v1.vault-auth-token.data["token"]
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
resource "vault_kubernetes_auth_backend_role" "tf-runner" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "tf-runner"
  bound_service_account_names      = ["tf-runner"]
  bound_service_account_namespaces = ["flux-system"]
  token_policies                   = ["readonly", "create-child-token"]
  audience                         = "https://kubernetes.default.svc.cluster.local"
}