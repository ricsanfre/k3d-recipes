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
  address = var.vault_address
  token   = var.vault_token
}