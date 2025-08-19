
.EXPORT_ALL_VARIABLES:
VAULT_WRAPPER=docker exec -it vault

.PHONY: all vault-start vault-init vault-unseal vault-status vault-kubernetes-auth vault-install vault-connect

default:
	all

vault-install: vault-start vault-init vault-unseal

vault-start:
	docker compose up -d

vault-init:
	${VAULT_WRAPPER} vault operator init -key-shares=1 -key-threshold=1 -format=json > unseal.json

vault-unseal:
	@${VAULT_WRAPPER} vault operator unseal $(shell jq -r '.unseal_keys_b64[0]' unseal.json)

vault-status:
	@${VAULT_WRAPPER} vault status

vault-kubernetes-auth:
	bash ../scripts/k8s-auth-method.sh

vault-connect:
	@${VAULT_WRAPPER} /bin/sh -c 'export VAULT_TOKEN='$(shell cat unseal.json | jq -r '.root_token')' && /bin/sh'


vault-configure-kv:
	vault secrets enable -version=2 -path=secret kv
	vault kv put secret/devwebapp/config username='giraffe' password='salsa'

vault-policy:
	vault policy write devwebapp - <<EOF
	path "secret/data/devwebapp/config" {
	capabilities = ["read"]
	}
	EOF

vault-role:
	vault write auth/kubernetes/role/devweb-app \
		bound_service_account_names=internal-app \
		bound_service_account_namespaces=default \
		policies=devwebapp \
		ttl=24h
