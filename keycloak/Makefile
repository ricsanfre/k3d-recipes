create-k3d:
	k3d cluster create mycluster -c k3d-cluster.yaml

delete-k3d:
	k3d cluster delete mycluster

helm-setup:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo add jetstack https://charts.jetstack.io
	helm repo add oauth2-proxy https://oauth2-proxy.github.io/manifests
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add elastic https://helm.elastic.co
	helm repo update

cert-manager-install:
	helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
	kubectl apply -f cluster-cert-issuer.yml
nginx-install:
	kubectl create namespace nginx
	helm install ingress-nginx ingress-nginx/ingress-nginx -f nginx-values.yml --namespace nginx

keycloak-install:
	kubectl create namespace keycloak
	kubectl apply -f keycloak-realm-configmap.yml
	helm install keycloak bitnami/keycloak -f keycloak-values.yml --namespace keycloak

keycloak-portforwarding:
	kubectl port-forward svc/keycloak 8081:80 -n keycloak

get-keycloak-admin-password:
	kubectl get secret keycloak -o jsonpath='{.data.admin-password}' -n keycloak | base64 -d && echo

proxy-oauth-install:
	kubectl create namespace oauth2-proxy
	helm install oauth2-proxy oauth2-proxy/oauth2-proxy -f oauth2-proxy-values.yml --namespace oauth2-proxy

prometheus-grafana-install:
	kubectl create namespace monitoring
	helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f prometheus-values.yml
	kubectl apply -f ingress.yaml

es-install:
	kubectl create namespace logging
	kubectl apply -f es-keycloak-secret.yml
	helm install elastic-operator elastic/eck-operator --namespace logging
	kubectl apply -f elasticsearch.yml
	kubectl apply -f kibana-ingress.yaml
get-es-passwd:
	kubectl get secret efk-es-elastic-user -o jsonpath='{.data.elastic}' -n logging | base64 -d;echo


testing-app:
	kubectl create namespace nginx-test
	kubectl apply -f test-app.yml