.PHONY: all clean base helm-setup strimzi-operator-install confluent-operator-install cnpg-install kafka-cluster kafka-clients kafka-producer kafka-consumer kafdrop apicurio-operator apicurio-registry

default:
	all

all:
	base helm-setup

clean:
	cd ../base && $(MAKE) $@

base:
	cd ../base && $(MAKE) K3D_SERVERS=1 K3D_AGENTS=3

helm-setup:
	helm repo add strimzi https://strimzi.io/charts/
	helm repo add confluentinc https://packages.confluent.io/helm
	helm repo add ricsanfre https://ricsanfre.github.io/helm-charts/
	helm repo add cnpg https://cloudnative-pg.github.io/charts
	helm repo update

strimzi-operator-install:
	helm upgrade --install strimzi-kafka-operator strimzi/strimzi-kafka-operator --namespace kafka --create-namespace \
	 --set generateNetworkPolicy=false

confluent-operator-install:
	helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes --namespace kafka --create-namespace
	helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes --namespace kafka \
	 --set kafka.bootstrapServers=cluster-kafka-bootstrap:9092 --set schemaRegistry.enabled=true

cnpg-install:
	helm install cloudnative-pg cnpg/cloudnative-pg --namespace databases --create-namespace \
	 --set crds.create=true

monitoring:
  podMonitorEnabled: false
  grafanaDashboard:
    create: true

kafka-cluster:
	kubectl kustomize cluster | kubectl apply -f -

kafdrop:
	kubectl kustomize kafdrop | kubectl apply -f -

kafka-clients:
	kubectl run kafka-clients --restart='Never' --image quay.io/strimzi/kafka:0.47.0-kafka-4.0.0 --namespace kafka --command -- sleep infinity
	kubectl cp producer.properties kafka/kafka-clients:/tmp/producer.properties
	kubectl cp consumer.properties kafka/kafka-clients:/tmp/consumer.properties

kafka-producer:
	kubectl exec -it kafka-clients --namespace kafka -- bin/kafka-console-producer.sh \
	--producer.config /tmp/producer.properties \
	--bootstrap-server cluster-kafka-bootstrap:9092 \
	--topic test-topic

kafka-consumer:
	kubectl exec -it kafka-clients --namespace kafka -- bin/kafka-console-consumer.sh \
	--consumer.config /tmp/consumer.properties \
	--bootstrap-server cluster-kafka-bootstrap:9092 \
	--topic test-topic \
	--group test-consumer-group --from-beginning

apicurio-operator:
	curl -sSL "https://raw.githubusercontent.com/Apicurio/apicurio-registry/v3.0.12/operator/install/install.yaml" | sed "s/PLACEHOLDER_NAMESPACE/kafka/g" | kubectl -n kafka apply -f -

apicurio-db:
	kubectl kustomize apicurio/db | kubectl apply -f -
apicurio-registry:
	kubectl kustomize apicurio/registry | kubectl apply -f -

kafka-avro-clients:
	kubectl run kafka-clients --restart='Never' --image ricsanfre/kafka-python-client:latest --namespace kafka --command -- sleep infinity
	kubectl cp producer.properties kafka/kafka-clients:/tmp/producer.properties
	kubectl cp consumer.properties kafka/kafka-clients:/tmp/consumer.properties

kafka-avro-producer:
	kubectl exec -it kafka-clients --namespace kafka -- python avro_producer.py \
	   -b cluster-kafka-bootstrap:9092 -s http://apicurioregistry-app-service:8080/apis/ccompat/v7 -t test-topic