# Istio installation

## Install istioctl

Install the istioctl binary with curl:

Download the latest release with the command:

```shell
curl -sL https://istio.io/downloadIstioctl | sh -
```

Add the istioctl client to your path, on a macOS or Linux system:

```shell
export PATH=$HOME/.istioctl/bin:$PATH
```

## Install Istio control plane

- Add helm repo
 
  ```shell
  helm repo add istio https://istio-release.storage.googleapis.com/charts
  helm repo update
  ``` 

- Create namespace

  ```shell
  kubectl create namespace istio-system
  ```

- Install base helm chart containing CRDs

  ```shell
  helm install istio-base istio/base -n istio-system
  ```

- Install isito discovery chart

  ```shell
  helm install istiod istio/istiod -n istio-system --set profile=demo
  ```

  `demo` profile is used in the installation

  Different profiles can be used during instalation. See [Istio configuration profiles](https://istio.io/latest/docs/setup/additional-setup/config-profiles/)

  Discovery helm chart: https://github.com/istio/istio/tree/master/manifests/charts/istio-control/istio-discovery


## Install Istio Gateway

- Create namespace

  ```shell
  kubectl create namespace istio-ingress
  ```

- Install isito discovery chart

  ```shell
  helm install istio-ingress istio/gateway -n istio-ingress --wait
  ```

## Install Kiali

https://www.lisenet.com/2023/kiali-does-not-see-istio-ingressgateway-installed-in-separate-kubernetes-namespace/


## Deploy sample application

[Book info sample application](https://istio.io/latest/docs/examples/bookinfo/) can be deployed to test installation

- Label namespace to enable automatic sidecar injection

  See https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#automatic-sidecar-injection

  ```shell
  kubectl label namespace default istio-injection=enabled 
  ```

- Install book info app

  ```shell
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.21/samples/bookinfo/platform/kube/bookinfo.yaml

  ```

- Deploy ingress

  ```shell
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.21/samples/bookinfo/networking/bookinfo-gateway.yaml
  ```

>  NOTE: Gateway object need to be reconfigured

  The selector matches the ingress gateway pod labels. If you installed Istio using Helm following the standard documentation, this would be "istio=ingress"

  server port need to be changed to port 80.

 - Validate configuration

   ```shell
   ioctl validate
   ```


## References

- Install istio using Helm chart: https://istio.io/latest/docs/setup/install/helm/ 
- Istio getting started: https://istio.io/latest/docs/setup/getting-started/
- Kiali: https://kiali.io/
