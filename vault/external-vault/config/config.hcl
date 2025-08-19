cluster_addr  = "https://vault.local.test:8201"
api_addr      = "https://vault.local.test:8200"
ui = true
plugin_directory = "/etc/vault/plugin"

log_requests_level = "debug"
log_level = "debug"

disable_mlock = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file      = "/certs/vault.crt"
  tls_key_file       = "/certs/vault.key"
  tls_disable_client_certs = true
 }

storage "raft" {
  path    = "/vault/data"
}

telemetry {
  disable_hostname = true
  prometheus_retention_time = "12h"
}