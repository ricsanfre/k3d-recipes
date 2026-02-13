terraform {
  required_version = ">= 1.0.0"
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.13.1"
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

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "vault" {
  # Configuration options
  address         = var.vault_address
  token           = var.vault_token
  skip_tls_verify = var.skip_tls_verify
}

data "kubernetes_secret_v1" "elastic_user_secret" {
  metadata {
    name      = "efk-es-elastic-user"
    namespace = "elastic"
  }
}

output "elastic_user_secret" {
  value     = data.kubernetes_secret_v1.elastic_user_secret.data["elastic"]
  sensitive = true
}

provider "elasticstack" {
  elasticsearch {
    # endpoints =  [ "https://elasticsearch.local.test" ]
    endpoints = ["${var.elasticsearch_endpoint}"]
    username  = var.elasticsearch_username
    password  = data.kubernetes_secret_v1.elastic_user_secret.data["elastic"]
    insecure  = var.skip_tls_verify
  }
  kibana {
    # endpoints = [ "https://kibana.local.test" ]
    endpoints = ["${var.kibana_endpoint}"]
    username  = var.elasticsearch_username
    password  = data.kubernetes_secret_v1.elastic_user_secret.data["elastic"]
    insecure  = var.skip_tls_verify
  }
}
