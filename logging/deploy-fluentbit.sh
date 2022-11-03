helm repo add fluent https://fluent.github.io/helm-charts
helm repo update
kubectl create namespace fluent
helm install fluentd fluent/fluentd -f fluentd-values.yml -n fluent
helm install fluent-bit fluent/fluent-bit -f fluentbit-values.yml -n fluent
