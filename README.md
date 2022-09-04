# K3D recipes

[k3d](https://k3d.io/) is a lightweight wrapper to run k3s (Rancher Lab’s minimal Kubernetes distribution) in docker.

This repo contains a set of recipes to configure and use k3d in different use cases.

## K3D installation

### Installation requirements

K3d requires to have installed the following components

- [docker](https://docs.docker.com/engine/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

### Installation procedure

To install, executes the following command:

```shell
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

### Creating cluster using a config file


Create config file containing configuration of the cluster

`k3d-cluster.yml`
```yml
apiVersion: k3d.io/v1alpha3
kind: Simple
name: mycluster-simple
servers: 1
agents: 2
```
This is a basic configuration creating a cluster with 1 k3s server and 2 k3s agents

And execute

```shell
k3d cluster create -c k3d-cluster.yml
```

## K3D behind a corporate HTTP proxy

HTTP_PROXY and HTTPS_PROXY environment variables need to be passed to k3d containers 

As stated in [K3d FAQ](https://k3d.io/v5.2.1/faq/faq/#running-behind-a-corporate-proxy), it also requires to validate corporate certificate within the containers. For doing that path to corparte CA certificate must be mounted in k3d containers.


```yml
apiVersion: k3d.io/v1alpha3
kind: Simple
name: mycluster-behind-corporate-proxy
servers: 1
agents: 2
volumes:
  - volume: /etc/ssl/certs/corporate-ca.pem:/etc/ssl/certs/corporate-ca.crt
env:
  - envVar: HTTP_PROXY=http://<corporate_proxy>:<port> 
    nodeFilters:
      - all
  - envVar: HTTPS_PROXY=http://<corporate_proxy>:<port>
    nodeFilters:
      - all
```

## Enabling access to K3s metrics endpoints

k3s arguments need to be passed to enabling remote monitoring to k3s metrics endpoints.
Within configuratoin file set the parameters under `options.k3s.extraArgs`

```yml
apiVersion: k3d.io/v1alpha3
kind: Simple
name: mycluster-with-metrics-exposed
servers: 1
agents: 2
options:
  k3s:
    extraArgs:
      - arg: --kube-proxy-arg=metrics-bind-address=0.0.0.0
        nodeFilters:
          - server:*
          - agent:*
      - arg: --kube-controller-manager-arg=bind-address=0.0.0.0
        nodeFilters:
          - server:*
      - arg: --kube-scheduler-arg=bind-address=0.0.0.0
        nodeFilters:
          - server:*
```

### Making traefik ingress accesible

For making accesible in localhost at 0.0.0.0:8080 the k3s loadbalancer where traefik is listening create the following k3d config file

```yml
apiVersion: k3d.io/v1alpha3
kind: Simple
name: mycluster-with-traefik-ingress-accesible
servers: 1
agents: 2
ports:
  - port: 8080:80 # same as `--port '8080:80@loadbalancer'`
    nodeFilters:
      - loadbalancer
```