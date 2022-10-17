kubectl create namespace fluent
helm install fluent-bit fluent/fluent-bit -f fluentbit-values.yml -n fluent --insecure-skip-tls-verify
