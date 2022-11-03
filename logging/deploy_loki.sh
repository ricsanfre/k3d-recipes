helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install loki grafana/loki --namespace loki --create-namespace -f loki-values.yml
helm install grafana grafana/grafana --namespace grafana --create-namespace -f grafana-values.yml
kubectl port-forward svc/grafana 3000:80 -n grafana
