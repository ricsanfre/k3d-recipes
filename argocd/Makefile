create-k3d:
	k3d cluster create mycluster -c ../k3d-cluster.yaml

delete-k3d:
	k3d cluster delete mycluster

helm-setup:
	helm repo add argo https://argoproj.github.io/argo-helm
	
argocd-install:
	kubectl create namespace argocd
	helm install argocd argo/argo-cd  --namespace argocd -f argocd-values.yml

argocd-install-behindproxy:
    # Run argocd behind proxy: https://github.com/argoproj/argo-cd/issues/7572
    kubectl create namespace argocd
    kubectl create secret generic custom-ca-certificates --from-file=custom-ca-certificates.crt=/etc/ssl/certs/huawei-ca.pem -n argocd
    helm install argocd argo/argo-cd  --namespace argocd -f argocd-values-http-proxy.yml