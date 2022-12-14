helm-setup:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo add fluent https://fluent.github.io/helm-charts
	helm repo update

loki-install:
	kubectl create namespace loki
	helm install loki grafana/loki --namespace loki -f loki-values.yml

fluent-install:
    kubectl create namespace fluent
	helm install fluentd fluent/fluentd -f fluentd-values.yml -n fluent
	helm install fluent-bit fluent/fluent-bit -f fluentbit-values.yml -n fluent

grafana-install:
	kubectl create namespace grafana
	helm install grafana grafana/grafana --namespace grafana -f grafana-values.yml

grafana-portforward:
	kubectl port-forward svc/grafana 3000:80 -n grafana