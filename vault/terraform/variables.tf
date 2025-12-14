variable "kubernetes_host" {
  type        = string
  description = "The Kubernetes API server host URL"
  default     = "http://example.com:443"
}

variable "vault_address" {
  type        = string
  description = "The address of the Vault server"
  default     = "http://vault.local.test:8200"
}
