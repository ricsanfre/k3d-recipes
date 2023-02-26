create-k3d:
	k3d cluster create mycluster -c ../k3d-cluster.yaml

delete-k3d:
	k3d cluster delete mycluster

helm-setup:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo add fluent https://fluent.github.io/helm-charts
	helm repo add elastic https://helm.elastic.co
	helm repo update


es-install:
	kubectl create namespace logging
	helm install elastic-operator elastic/eck-operator --namespace logging
	kubectl apply -f elasticsearch.yml

get-es-passwd:
	kubectl get secret efk-es-elastic-user -o jsonpath='{.data.elastic}' -n logging | base64 -d;echo

kibana-port-forward:
	kubectl port-forward svc/kibana-kb-http 5601:5601 -n es

loki-install:
	kubectl create namespace logging
	helm install loki grafana/loki --namespace logging -f loki-values.yml

fluent-install-loki:
	helm install fluentd fluent/fluentd -f fluentd-values.yml -n logging
	helm install fluent-bit fluent/fluent-bit -f fluentbit-values.yml -n logging

fluent-install-es:
	helm install fluentd fluent/fluentd -f fluentd-values-es.yml -n logging
	helm install fluent-bit fluent/fluent-bit -f fluentbit-values.yml -n logging

grafana-install:
	kubectl create namespace grafana
	helm install grafana grafana/grafana --namespace grafana -f grafana-values.yml

grafana-portforward:
	kubectl port-forward svc/grafana 3000:80 -n grafana