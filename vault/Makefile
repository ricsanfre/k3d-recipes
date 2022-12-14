# https://www.virtualizationhowto.com/2022/11/install-hashicorp-vault-in-kubernetes/
# https://colinwilson.uk/2022/03/27/secret-management-with-gitops-and-argo-cd-vault-plugin/

export VAULT_TOKEN=$(shell cat unseal.json | jq -r '.root_token')
export VAULT_ADDR=localhost:8200

create-k3d:
  k3d cluster create mycluster -c ../k3d-cluster.yaml

delete-k3d:
  k3d cluster delete mycluster

helm-setup:
  helm repo add hashicorp https://helm.releases.hashicorp.com
	
vault-install:
  kubectl create namespace vault
  helm upgrade --install --namespace=vault vault hashicorp/vault

vault-init:
  kubectl exec -ti --namespace=vault vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > unseal.json
  kubectl exec -ti --namespace=vault vault-0 -- vault operator unseal

vault-port-forward: # Execute in a different terminal
  kubectl port-forward --namespace=vault svc/vault 8200

vault-connect:
  @kubectl exec -ti --namespace=vault vault-0 -- /bin/sh -c 'export VAULT_TOKEN='$(shell cat unseal.json | jq -r '.root_token')' && /bin/sh'

vault-auth-method:
  vault auth enable kubernetes
  vault write auth/kubernetes/config \
    issuer="" \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault-enable-kv:
  vault secrets enable -version=2 kv

vault-put-get-secrets:
  vault kv put kv/micamara/supersecret user="yo" password="misecreto"
  vault kv get kv/micamara/supersecret