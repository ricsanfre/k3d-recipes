kubectl create namespace monitoring
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f prometheus-values.yml
kubectl apply -f traefik-ingress.yml
