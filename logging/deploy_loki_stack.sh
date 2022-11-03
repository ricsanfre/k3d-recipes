helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install loki grafana/loki-stack --namespace loki --create-namespace --set grafana.enabled=true
