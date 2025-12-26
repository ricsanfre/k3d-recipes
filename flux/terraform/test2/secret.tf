data "vault_kv_secret_v2" "elastic-admin" {
  mount = var.vault_kv2_path
  name  = "elastic/admin"
}

output "elastic_admin_credentials" {
  value     = data.vault_kv_secret_v2.elastic-admin.data
  sensitive = true
}   