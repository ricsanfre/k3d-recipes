## Linkerd traces integration in Grafana Tempo

### Install linkerd using Helm chart

- Step 1: Create Linkerd Issuer certificate and key

 Using [small-step](https://smallstep.com/certificates/) tool 

  ```shell
  step certificate create root.linkerd.cluster.local ca.crt ca.key --profile root-ca --no-password --insecure
  step certificate create identity.linkerd.cluster.local issuer.crt issuer.key --profile intermediate-ca --not-after 8760h --no-password --insecure --ca ca.crt --ca-key ca.key
  ```

- Step 2: Add linkerd repo

  ```shell
  helm repo add linkerd https://helm.linkerd.io/stable
  ```

- Step 2: Install linkerd CRDs helm chart
 
  ```shell
  helm install linkerd-crds linkerd/linkerd-crds  -n linkerd --create-namespace
  ```

- Step 3: Install linkerd control plane helm chart
  
  ```shell
  helm install linkerd-control-plane -n linkerd --set-file identityTrustAnchorsPEM=ca.crt --set-file identity.issuer.tls.crtPEM=issuer.crt --set-file identity.issuer.tls.keyPEM=issuer.key linkerd/linkerd-control-plane
  ```

### Install Tempo

> Tempo need to be meshed with linkerd. Otherwise linkerd-proxy components fail to connect tempo-distributor component (OpenTelemetry collector), used for colect linkerd-proxy traces span

- Step 1: Add repository

  ```shell
  helm repo add grafana https://grafana.github.io/helm-charts
  helm repo update
  ```

- Step 2: Prepare tempo-values.yml file

  ```yml
  # Annotate pods so linkerd can inject linkerd-proxy
  tempo:
  podAnnotations:
    linkerd.io/inject: enabled

  # Enable trace ingestion
  traces:
    otlp:
        grpc:
        enabled: true
        http:
        enabled: true
    zipkin:
        enabled: true
    jaeger:
        thriftCompact:
        enabled: true
        thriftHttp:
        enabled: true
    opencensus:
        enabled: true
  # Configure S3 backend
  storage:
    trace:
        backend: s3
        s3:
        bucket: tempo-traces
        endpoint: tempo-minio:9000
        access_key: tempo
        secret_key: supersecret
        insecure: true
  distributor:
    config:
        log_received_spans:
        enabled: true
  
  # Minio backend deployment
  minio:
    enabled: true
    mode: standalone
    secretKey: supersecret
    accessKey: tempo
    rootUser: tempo
    rootPassword: supersecret
    buckets:
        - name: tempo-traces
        policy: none
        purge: false
        - name: enterprise-traces
        policy: none
        purge: false
        - name: enterprise-traces-admin
        policy: none
        purge: false

  ```
  > linkerd annotation at namespace level does not work, since minio installation deploys a kubernetes job to create S3 bucket.
  
- Step 3: Install helm chart

  ```shell
  helm install tempo grafana/tempo-distributed --create-namespace --namespace tempo -f tempo-values.yml
  ```

### Install Grafana

- Step 1: Prepare grafana-values.yml file

  ```yml
  adminPassword: s1cret0
  datasources:
    datasources.yaml:
        apiVersion: 1
        datasources:
        - name: Loki
        type: loki
        access: proxy
        url: http://loki-gateway.loki.svc.cluster.local
        - name: Tempo
        type: tempo
        access: proxy
        url: http://tempo-query-frontend.tempo.svc.cluster.local:3100
  ```

- Step 2: Intall grafana Helm chart

  ```shell
  helm install grafana grafana/grafana --namespace grafana --create-namespace -f grafana-values.yml
  ```

### Linkerd traces integration

[Linkerd-jaeger extension](https://linkerd.io/2.12/tasks/distributed-tracing/) is needed for activating the emisson of traces of linkerd-proxys components.

Linkerd jaegger extension, by default, installs Jaeger, as tracing solution backend, OpenTelemetry collector, to collect and distribute traces to Jaeger backend and Jaegger-injector, responsible for configuring the Linkerd proxies to emit spans.

Tempo will be used, instead of Jaeger, and Tempo distributor component has a embedded OpenTelemetry collector. So non of those components will be installe. Only jaeger-injector needs to be installed.

- Step 1. Prepare linked-jaeger-values.yml

  ```yml
  collector:
    enabled: false
  jaeger:
    enabled: false
  webhook:
    collectorSvcAddr: tempo-distributor.tempo:55678
    collectorSvcAccount: tempo
  ```
  This configuration disables Jaeger and OTel Collector installation and configures jaeger-injector to send traces span to tempo-distributor component using OpenCensus receiver (port 55678)

  `webhook.collectorSvcAddr` is OpenCensus endpoint distributor receiver
  `webhook.collectorSvcAccount` is service account name used by Tempo.

- Step 2. Install jaeger-extensiong helm chart

  ```shell
  helm install linkerd-jaeger -n linkerd-jaeger --create-namespace linkerd/linkerd-jaeger -f linkerd-jaeger-values.yml
  ```

## Testing with Emojivoto application

- Step 1: Install emojivoto application using linkerd cli
  ```shell
  linkerd inject https://run.linkerd.io/emojivoto.yml | kubectl apply -f -
  ```

- Step 2: Configure emojivoto applicatio to emit spans to Tempo

  ```shell
  kubectl -n emojivoto set env --all deploy OC_AGENT_HOST=tempo-distributor.tempo:55678
  ```

