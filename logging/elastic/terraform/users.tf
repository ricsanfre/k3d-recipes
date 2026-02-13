# Locals

# This local variable `users` defines the users to be created in Elasticsearch. 
# The user definitions are read from JSON files in the "users" directory.
# Each JSON file should contain the user's roles, full name, email, and a reference to a Vault key for the password
# JSON structure is the same payload required by the Elasticsearch API for user creation except for the password, which is read from Vault using the `vault_password_key` field in the JSON file
#    ref: https://www.elastic.co/docs/api/doc/elasticsearch/operation/operation-security-put-user
# File name indicates the username, and the content of the file should be a JSON object with the following structure:
# {
#   "vault_secret_key" : "vault/path/to/secret",
#   "roles" : [ "role1", "role2" ],
#   "full_name" : "User Full Name",
#   "email" : "User Email",
#   "metadata" : {
#     "key1" : "value1",
#     "key2" : "value2"
# }
# Sample file:
# fluentd.json
# {
#   "vault_secret_key" : "elastic/fluentd",
#   "roles" : [ "admin", "other_role1" ],
#   "full_name" : "Fluetd User",
#   "email" : "fluentdh@example.com",
#   "metadata" : {
#     "service_account" : true
#   }
# }
# `users` local variable is a map of objects, where the key is the name of the file (user name) and the value is an object containing the json content of the file

locals {
  json_user_files = fileset(path.module, "users/*.json")
  users           = { for f in local.json_user_files : regex("^(.+/)*(.+)\\.(.+)$", f)[1] => jsondecode(file("${path.module}/${f}")) }
}


ephemeral "vault_kv_secret_v2" "user_passwords" {
  for_each = local.users
  mount    = var.vault_kv2_path
  name     = each.value.vault_secret_key
}

resource "elasticstack_elasticsearch_security_user" "users" {
  for_each            = local.users
  username            = each.key
  roles               = each.value.roles
  full_name           = can(each.value.full_name) ? each.value.full_name : null
  email               = can(each.value.email) ? each.value.email : null
  password_wo         = tostring(ephemeral.vault_kv_secret_v2.user_passwords[each.key].data["password"])
  password_wo_version = 1
  metadata            = can(each.value.metadata) ? jsonencode(each.value.metadata) : null

}

output "users" {
  value     = elasticstack_elasticsearch_security_user.users
  sensitive = true
}