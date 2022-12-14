linkerd-certs:
    step certificate create root.linkerd.cluster.local ca.crt ca.key --profile root-ca --no-password --insecure
	step certificate create identity.linkerd.cluster.local issuer.crt issuer.key --profile intermediate-ca --not-after 8760h --no-password --insecure --ca ca.crt --ca-key ca.key

helm-setup:
	helm repo add linkerd https://helm.linkerd.io/stable
	
linkerd-install:
	kubectl create namespace linkerd
	helm install linkerd-crds linkerd/linkerd-crds  -n linkerd
	helm install linkerd-control-plane -n linkerd --set-file identityTrustAnchorsPEM=ca.crt --set-file identity.issuer.tls.crtPEM=issuer.crt --set-file identity.issuer.tls.keyPEM=issuer.key linkerd/linkerd-control-plane

deploy-emojivoto:
	linkerd inject https://run.linkerd.io/emojivoto.yml | kubectl apply -f -

