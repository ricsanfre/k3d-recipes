.EXPORT_ALL_VARIABLES:
DATE_NOW=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ" --date 'now')
DATE_5MIN_AGO=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ" --date 'now - 5 minutes')
PROM_SINGLE_METRIC=node_memory_MemTotal_bytes{instance="172.23.0.2:9100"}
# PROM_FORMULA=node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes
# PROM_FORMULA=(1 - (node_memory_MemAvailable_bytes{instance="172.23.0.2:9100"} / node_memory_MemAvailable_bytes{instance="172.23.0.2:9100"})) * 100
# PROM_FORMULA=count(node_cpu_seconds_total) by (instance, mode)
PROM_FORMULA=sum by (instance,cpu) (node_cpu_seconds_total)

default: all

.PHONY: all clean base helm-setup promtheus-stack-install grafana-install prometheus-portforward grafana-portforward query-range-single-metric query-range-formula

all: base helm-setup prometheus-stack-install

clean:
	cd ../base && $(MAKE) $@

base:
	cd ../base && $(MAKE) K3D_SERVERS=3 K3D_AGENTS=3

helm-setup:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update

prometheus-stack-install:
	helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
	  -f prometheus-values.yml,prometheus-values-k3s-sol2.yaml \
	  -f prometheus-values-disable-grafana.yaml \
	  --namespace kube-prom-stack --create-namespace

grafana-install:
	helm upgrade --install grafana grafana/grafana -f grafana-values.yaml --namespace grafana --create-namespace

prometheus-portforward:
	kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring

grafana-portforward:
	kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring

query-range-single-metric:
	curl http://localhost:9090/api/v1/query_range --data-urlencode 'query=${PROM_SINGLE_METRIC}' --data-urlencode 'start=${DATE_5MIN_AGO}' --data-urlencode 'end=${DATE_NOW}' --data-urlencode 'step=15s' | jq 

query-range-formula:
	curl http://localhost:9090/api/v1/query_range --data-urlencode 'query=${PROM_FORMULA}' --data-urlencode 'start=${DATE_5MIN_AGO}' --data-urlencode 'end=${DATE_NOW}' --data-urlencode 'step=15s' | jq 
