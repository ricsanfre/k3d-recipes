# Create KV2 access policies
# Read-only
resource "vault_policy" "readonly" {
  name   = "readonly"
  policy = <<-EOT
  path "secret/*" {
    capabilities = ["read", "list"]
  }
  EOT
}

# Write
resource "vault_policy" "readwrite" {
  name   = "readwrite"
  policy = <<-EOT
   path "secret/*" {
     capabilities = ["create", "read", "update", "delete", "list", "patch"]
   }
   EOT
}

# Token management
resource "vault_policy" "create-child-token" {
  name   = "create-token"
  policy = <<-EOT
    path "auth/token/create" {
        capabilities = [ "update" ]
    }
    EOT
}