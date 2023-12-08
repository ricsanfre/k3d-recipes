create-k3d:
	k3d cluster create mycluster -c k3d-cluster.yaml

delete-k3d:
	k3d cluster delete mycluster

helm-setup:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo add jetstack https://charts.jetstack.io
	helm repo update

cert-manager-install:
	helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
	kubectl apply -f cluster-cert-issuer.yml
nginx-install:
	kubectl create namespace nginx
	helm install ingress-nginx ingress-nginx/ingress-nginx -f nginx-values.yml --namespace nginx

keycloak-install:
	kubectl create namespace keycloak
	helm install keycloak bitnami/keycloak -f keycloak-values.yml --namespace keycloak

keycloak-portforwarding:
	kubectl port-forward svc/keycloak 8081:80 -n keycloak

get-keycloak-admin-password:
	kubectl get secret keycloak -o jsonpath='{.data.admin-password}' -n keycloak | base64 -d && echo