linkerd-certs:
    step certificate create root.linkerd.cluster.local ca.crt ca.key --profile root-ca --no-password --insecure
	step certificate create identity.linkerd.cluster.local issuer.crt issuer.key --profile intermediate-ca --not-after 8760h --no-password --insecure --ca ca.crt --ca-key ca.key

helm-setup:
	helm repo add linkerd https://helm.linkerd.io/stable
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo add traefik https://helm.traefik.io/traefik
	helm repo add fluent https://fluent.github.io/helm-charts
	helm repo update
	
linkerd-install:
	kubectl create namespace linkerd
	helm install linkerd-crds linkerd/linkerd-crds  -n linkerd
	helm install linkerd-control-plane -n linkerd --set-file identityTrustAnchorsPEM=ca.crt --set-file identity.issuer.tls.crtPEM=issuer.crt --set-file identity.issuer.tls.keyPEM=issuer.key linkerd/linkerd-control-plane

tempo-install:
    kubectl create namespace tempo
	helm install tempo grafana/tempo-distributed --namespace tempo -f tempo-values.yml

loki-install:
	kubectl create namespace loki
	helm install loki grafana/loki --namespace loki -f loki-values.yml

fluent-install:
    kubectl create namespace fluent
	helm install fluentd fluent/fluentd -f fluentd-values.yml -n fluent
	helm install fluent-bit fluent/fluent-bit -f fluentbit-values.yml -n fluent

traefik-install:
    # install traefik exporting traces to tempo
	kubectl create namespace traefik
	helm install traefik traefik/traefik --create-namespace -n traefik -f traefik-values.yml

grafana-install:
	kubectl create namespace grafana
	helm install grafana grafana/grafana --namespace grafana -f grafana-values.yml

linkerd-jaeger:
	helm install linkerd-jaeger -n linkerd-jaeger --create-namespace linkerd/linkerd-jaeger -f linkerd-jaeger-nocolector-values.yml

deploy-emojivoto:
	linkerd inject https://run.linkerd.io/emojivoto.yml | kubectl apply -f -
	kubectl -n emojivoto set env --all deploy OC_AGENT_HOST=tempo-distributor.tempo:55678
	kubectl apply -f traefik-ingress.yml