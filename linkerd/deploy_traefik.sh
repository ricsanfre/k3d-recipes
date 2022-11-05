kubectl create namespace traefik
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik --create-namespace -n traefik -f traefik-values.yml
