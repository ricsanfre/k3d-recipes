terraform {
  required_version = ">= 1.0.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.6.0"
    }
  }
}

provider "random" {
  # Configuration options
}

provider "kubernetes" {
  // in-cluster configuration
  // ref: https://search.opentofu.org/provider/opentofu/kubernetes/latest#in-cluster-config
  // ref: https://github.com/hashicorp/terraform-provider-kubernetes/tree/main/_examples/in-cluster
}


provider "vault" {
  # Configuration options
  address         = var.vault_address
  skip_tls_verify = var.vault_skip_tls_verify
  auth_login {
    path = "auth/kubernetes/login"
    parameters = {
      role = "${var.vault_k8s_role}"
      jwt  = "${file("${var.vault_k8s_token_path}")}"
    }
  }
}

# provider "vault" {
#   address = var.vault_address
#   skip_tls_verify = var.vault_skip_tls_verify
#   auth_login_jwt {
#     mount = "kubernetes"
#     role = "${var.vault_k8s_role}"
#     jwt = file("${var.vault_k8s_token_path}")
#   }
# }