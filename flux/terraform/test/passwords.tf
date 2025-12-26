locals {
  json_files = fileset(path.module, "secrets/*.json")
  json_data  = { for f in local.json_files : regex("^(.+/)*(.+)\\.(.+)$", f)[1] => jsondecode(file("${path.module}/${f}")) }
  secrets = merge([
    for key, group in local.json_data : {
      for subkey, secret in group :
      "${key}/${subkey}" => secret
    }
  ]...)
}

output "secrets_local" {
  value = local.secrets
}

# Random passsword first character to ensure it starts with a letter
resource "random_string" "first_char" {
  for_each = local.secrets
  length   = 1
  special  = false
  upper    = true
  lower    = true
}


resource "random_password" "password" {
  for_each = local.secrets
  length   = 15
  special  = false
  #   override_special = "!#$%&*()-_=+[]{}<>:?"
}


locals {
  secrets_data = {
    for key, secret in local.secrets :
    key => {
      content = merge(
        secret.content,
        {
          "${secret.secret_name}" = "${random_string.first_char[key].result}${random_password.password[key].result}"
        }
      )
    }
  }
}

output "secrets_data_local" {
  value     = local.secrets_data
  sensitive = true
}