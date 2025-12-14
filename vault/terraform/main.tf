terraform {
  required_version = ">= 1.0.0"
  required_providers {
    random = {
      source  = "opentofu/random"
      version = "3.7.2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.6.0"
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
  config_path = "~/.kube/config"
}

provider "vault" {
  # Configuration options
  address = var.vault_address
}