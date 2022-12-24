# https://www.virtualizationhowto.com/2022/11/install-hashicorp-vault-in-kubernetes/
# https://colinwilson.uk/2022/03/27/secret-management-with-gitops-and-argo-cd-vault-plugin/

export VAULT_TOKEN=$(shell cat unseal.json | jq -r '.root_token')
export VAULT_ADDR=http://localhost:8200

create-k3d:
	k3d cluster create mycluster -c ../k3d-cluster.yaml

delete-k3d:
	k3d cluster delete mycluster

helm-setup:
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm repo add external-secrets https://charts.external-secrets.io

vault-install:
	kubectl create namespace vault
	helm upgrade --install --namespace=vault vault hashicorp/vault

vault-init:
	kubectl exec -ti --namespace=vault vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > unseal.json

vault-unseal:
	@kubectl exec -ti --namespace=vault vault-0 -- vault operator unseal $(shell cat unseal.json | jq -r '.unseal_keys_b64[0]')

eso-install:
	kubectl create namespace external-secrets
	helm install external-secrets \
	   external-secrets/external-secrets \
	    -n external-secrets \
	    --set installCRDs=true

vault-port-forward: # Execute in a different terminal
	kubectl port-forward --namespace=vault svc/vault 8200

vault-connect:
	@kubectl exec -ti --namespace=vault vault-0 -- /bin/sh -c 'export VAULT_TOKEN='$(shell cat unseal.json | jq -r '.root_token')' && /bin/sh'

vault-kubernetes-auth:
	kubectl apply -f manifest/vault-auth-serviceaccount.yaml
	bash scripts/k8s-auth-method.sh

vault-configure-kv:
	vault secrets enable -version=2 -path=secret kv 
	vault policy write read-secrets policy/read-policy.hcl
	vault write auth/kubernetes/role/read-only \
		bound_service_account_names= \
		bound_service_account_namespaces=expenses \
		policies=read-secrets \
		ttl=1h

vault-put-get-secrets:
	vault kv put kv/micamara/supersecret user="yo" password="misecreto"
	vault kv get kv/micamara/supersecret