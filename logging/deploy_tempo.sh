helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install tempo grafana/tempo-distributed --namespace tempo --create-namespace -f tempo-values.yml
