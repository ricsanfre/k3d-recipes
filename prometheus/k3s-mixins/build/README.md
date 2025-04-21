# Kube Prometheus Stacks Mixins for K3s

The kube-prometheus-stack Helm chart, which deploys the kubernetes-mixin, targets standard Kubernetes setups, often pre-configured for specific cloud environments. However, these configurations aren’t directly compatible with k3s, a lightweight Kubernetes distribution. Since k3s lacks many of the default cloud integrations, issues arise, such as missing metrics, broken graphs, and unavailable endpoints.

This blog post guides you through adapting the kube-prometheus-stack Helm chart and the kubernetes-mixin to work seamlessly in k3s environments, ensuring functional dashboards and alerts tailored to k3s

## kubernetes-mixin Configuration

The kube-prometheus-stack Helm chart uses the kube-prometheus project as a baseline for the Helm chart. The kube-prometheus project is a collection of Kubernetes manifests, Grafana dashboards and Prometheus rules combined with Jsonnet libraries to generate them. The kube-prometheus project uses monitoring mixins to generate alerts and dashboards. Monitoring mixins are a collection of Jsonnet libraries that generate dashboards and alerts for Kubernetes. 

-  The kubernetes-mixin is a mixin that generates dashboards and alerts for Kubernetes.
-  The node-exporter, coredns, grafana, prometheus and prometheus-operator mixins are also used to generate dashboards and alerts for the Kubernetes cluster.

## Credits

https://hodovi.cc/blog/configuring-kube-prometheus-stack-dashboards-and-alerts-for-k3s-compatibility/