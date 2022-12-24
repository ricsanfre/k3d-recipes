#!/bin/bash


# Get Service Account token
KUBERNETES_SA_SECRET_NAME=$(kubectl get secrets --output=json -n vault | jq -r '.items[].metadata | select(.name|startswith("vault-auth")).name')
TOKEN_REVIEW_JWT=$(kubectl get secret $KUBERNETES_SA_SECRET_NAME -n vault -o jsonpath='{.data.token}' | base64 --decode)

# Get Kubernetes CA
KUBERNETES_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
KUBERNETES_SA_CA_CERT=$(kubectl get secrets -n vault $KUBERNETES_SA_SECRET_NAME -o jsonpath="{.data['ca\.crt']}" | base64 -d)
# Get Kubernetes Url
KUBERNETES_HOST=$(kubectl config view -o jsonpath='{.clusters[].cluster.server}')

# Enable kuberentes auth
vault auth enable kubernetes

# Configure kubernetes auth
vault write auth/kubernetes/config  \
    token_reviewer_jwt="${TOKEN_REVIEW_JWT}" \
    kubernetes_host="${KUBERNETES_HOST}" \
    kubernetes_ca_cert="${KUBERNETES_CA_CERT}"
