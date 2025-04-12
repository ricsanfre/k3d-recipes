
default: all

.PHONY : all
all: helm-setup create-k3d cert-manager-install nginx-install

.PHONY: clean
clean: delete-k3d

.PHONY : create-k3d
create-k3d:
	k3d cluster create mycluster -c k3d-cluster.yaml

.PHONY : delete-k3d
delete-k3d:
	k3d cluster delete mycluster

.PHONY : helm-setup
helm-setup:
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo add jetstack https://charts.jetstack.io
	helm repo update

cert-manager-install:
	helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set crds.enabled=true
	kubectl apply -f cert-manager/cluster-cert-issuer.yml

nginx-install:
	helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -f nginx/nginx-values.yml --namespace nginx --create-namespace

