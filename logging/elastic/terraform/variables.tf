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

variable "vault_token" {
  type        = string
  description = "Vault token to be used during authentication"
  sensitive   = true
}

variable "skip_tls_verify" {
  type        = bool
  description = "Skip TLS verification when connecting to all services"
  default     = true
}

variable "vault_kv2_path" {
  type        = string
  description = "Path to the KV v2 secrets engine in Vault"
  default     = "secret"
}

variable "elasticsearch_endpoint" {
  type        = string
  description = "Elasticsearch endpoints"
  default     = "https://elasticsearch.local.test"
}

variable "kibana_endpoint" {
  type        = string
  description = "Kibana endpoints"
  default     = "https://kibana.local.test"
}

variable "elasticsearch_username" {
  type        = string
  description = "Username for Elasticsearch and Kibana"
  default     = "elastic"
}