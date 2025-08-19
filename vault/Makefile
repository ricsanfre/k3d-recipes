# https://www.virtualizationhowto.com/2022/11/install-hashicorp-vault-in-kubernetes/
# https://colinwilson.uk/2022/03/27/secret-management-with-gitops-and-argo-cd-vault-plugin/

.EXPORT_ALL_VARIABLES:

VAULT_TOKEN=$(shell cat unseal.json | jq -r '.root_token')
VAULT_ADDR=http://localhost:8200
VAULT_WRAPPER=kubectl exec -ti --namespace=vault vault-0 --

.PHONY: all clean base helm-setup vault-install vault-init vault-unseal eso-install vault-connect vault-install-external vault-install-external-helm

default:
	all

all:
	base helm-setup

clean:
	cd ../base && $(MAKE) $@

base:
	cd ../base && $(MAKE) K3D_SERVERS=1 K3D_AGENTS=3

helm-setup:
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm repo add external-secrets https://charts.external-secrets.io

vault-install:
	kubectl create namespace vault
	helm upgrade --install --namespace=vault vault hashicorp/vault

vault-init:
	${VAULT_WRAPPER} vault operator init -key-shares=1 -key-threshold=1 -format=json > unseal.json

vault-unseal:
	@${VAULT_WRAPPER} vault operator unseal $(shell cat unseal.json | jq -r '.unseal_keys_b64[0]')

eso-install:
	kubectl create namespace external-secrets
	helm install external-secrets \
	   external-secrets/external-secrets \
	    -n external-secrets \
	    --set installCRDs=true

vault-port-forward: # Execute in a different terminal
	kubectl port-forward --namespace=vault svc/vault 8200

vault-connect:
	@${VAULT_WRAPPER} /bin/sh -c 'export VAULT_TOKEN='$(shell cat unseal.json | jq -r '.root_token')' && /bin/sh'

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

# External Vault

vault-install-external:
	cd external-vault && $(MAKE) vault-install

vault-install-external-helm:
	kubectl create namespace vault
	helm upgrade --install --namespace=vault vault hashicorp/vault -f vault-values.yaml

vault-external-kubernetes-auth:
	kubectl apply -f manifest/vault-secret.yaml
	cd external-vault && $(MAKE) vault-kubernetes-auth

# Prometheus
prometheus-stack-install:
	helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
	  -f ../prometheus/prometheus-values.yml,../prometheus/prometheus-values-k3s-sol2.yaml \
	  -f ../prometheus/prometheus-values-disable-grafana.yaml \
	  -f prometheus-values-vault-annotations.yaml \
	  --namespace kube-prom-stack --create-namespace

