
# Enable KV Version 2 Secret Engine
# ref: https://search.opentofu.org/provider/hashicorp/vault/latest/docs/resources/mount
resource "vault_mount" "kv_engine_v2" {
  path = "secret"
  type = "kv-v2"
  options = {
    version = "2"
    type    = "kv-v2"
  }
  description = "KV Version 2 secret engine mount"
}


# Create secret in KV Version 2 Secret Engine

resource "vault_kv_secret_v2" "secrets" {
  for_each            = local.secrets_data
  mount               = vault_mount.kv_engine_v2.path
  name                = each.key
  cas                 = 1
  delete_all_versions = true
  data_json           = jsonencode(each.value.content)
}