create-k3d:
	k3d cluster create mycluster -c k3d-cluster.yaml

delete-k3d:
	k3d cluster delete mycluster


helm-setup:
	helm repo add istio https://istio-release.storage.googleapis.com/charts
	helm repo add kiali https://kiali.org/helm-charts
	helm repo update
	
istio-control-install:
	kubectl create namespace istio-system
	helm install istio-base istio/base -n istio-system
	helm install istiod istio/istiod -n istio-system --set profile=demo

istio-gateway-install:
	kubectl create namespace istio-ingress
	helm install istio-ingress istio/gateway -n istio-ingress

kiali-install:
	helm install kiali-server kiali/kiali-server --namespace istio-system -f kiali-values.yaml

kiali-port-forward:
	kubectl port-forward svc/kiali 20001:20001 -n istio-system

deploy-sample-app:
	kubectl label namespace default istio-injection=enabled
	kubectl apply -f bookinfo.yaml

configure-gateway:
	kubectl apply -f bookinfo-gateway.yaml

verify:
	kubectl exec $$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"


