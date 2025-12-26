variable "kubernetes_host" {
  type        = string
  description = "The Kubernetes API server host URL"
  default     = "http://example.com:443"
}

variable "vault_address" {
  type        = string
  description = "The address of the Vault server"
  default     = "http://vault.com:8200"
}

variable "vault_k8s_role" {
  type        = string
  description = "K8s role to be used during authentication"
  default     = "tf-runner"
}

variable "vault_k8s_token_path" {
  type        = string
  description = "Path to k8s token path to be used during authentication"
  default     = "/var/run/secrets/kubernetes.io/serviceaccount/token"
}

variable "vault_kv2_path" {
  type        = string
  description = "Path to the KV v2 secrets engine in Vault"
  default     = "secret"
}

variable "vault_skip_tls_verify" {
  type        = bool
  description = "Skip TLS verification when connecting to Vault"
  default     = true
}
