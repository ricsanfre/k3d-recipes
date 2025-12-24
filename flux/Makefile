.PHONY: all clean base helm-setup flux-operator-install flux-instance-install flux-tofu-install

default:
	all

all:
	base helm-setup

clean:
	cd ../base && $(MAKE) $@

base:
	cd ../base && $(MAKE) K3D_SERVERS=1 K3D_AGENTS=3

helm-setup:
	helm repo add tofu-controller https://flux-iac.github.io/tofu-controller

flux-operator-install:
	helm install flux-operator oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator \
  	--namespace flux-system	--create-namespace

flux-instance-install:
	helm install flux-instance oci://ghcr.io/controlplaneio-fluxcd/charts/flux-instance \
  	--namespace flux-system -f flux-instance-values.yaml

flux-tofu-install:
	helm upgrade -i tofu-controller tofu-controller/tofu-controller \
	--version v0.16.0-rc.7 \
    --namespace flux-system