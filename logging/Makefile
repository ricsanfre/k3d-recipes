
.PHONY: all clean base helm-setup es-install es-exporter get-es-password kibana-port-forward loki-install fluent-install

clean:
	cd ../base && $(MAKE) $@

base:
	cd ../base && $(MAKE) K3D_SERVERS=1 K3D_AGENTS=2

helm-setup:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo add fluent https://fluent.github.io/helm-charts
	helm repo add elastic https://helm.elastic.co
	helm repo add mongodb https://mongodb.github.io/helm-charts
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update

es-install:
	kubectl create namespace elastic
	helm upgrade --install elastic-operator elastic/eck-operator --namespace elastic
	kubectl kustomize elastic | kubectl apply -f -

es-exporter:
	helm upgrade --install -f prometheus-es-exporter-values.yaml prometheus-elasticsearch-exporter prometheus-community/prometheus-elasticsearch-exporter --namespace elastic 

mongodb-install:
	kubectl create namespace mongodb
	helm install community-operator mongodb/community-operator --namespace mongodb
	kubectl apply -f mongodb-database.yaml

mongodb-get-connection-string:
	kubectl get secret example-mongodb-admin-my-user -n mongodb -o json | jq -r '.data | with_entries(.value |= @base64d)'

mongosh:
	kubectl run -n mongodb --it mongo-shell --image=mongo --rm -- /mongosh

get-es-passwd:
	kubectl get secret efk-es-elastic-user -o jsonpath='{.data.elastic}' -n elastic | base64 -d;echo

kibana-port-forward:
	kubectl port-forward svc/efk-kb-http 5601:5601 -n elastic

loki-install:
	kubectl create namespace loki
	helm install loki grafana/loki --namespace loki -f loki-values.yml

fluent-install:
	kubectl create namespace fluent
	kubectl kustomize fluentd | kubectl apply -f -
	kubectl kustomize fluent-bit | kubectl apply -f -
	helm install fluentd fluent/fluentd -f fluentd-values.yml -n fluent
	helm install fluent-bit fluent/fluent-bit -f fluentbit-values.yml -n fluent

grafana-install:
	kubectl create namespace grafana
	helm install grafana grafana/grafana --namespace grafana -f grafana-values.yml

grafana-portforward:
	kubectl port-forward svc/grafana 3000:80 -n grafana