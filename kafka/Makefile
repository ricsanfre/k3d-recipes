.PHONY: all clean base helm-setup strimzi-operator-install confluent-operator-install kafka-cluster kafka-clients kafka-producer kafka-consumer

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
	helm repo update

strimzi-operator-install:
	helm upgrade --install sstrimzi-kafka-operator strimzi/strimzi-kafka-operator --namespace kafka --create-namespace

confluent-operator-install:
	helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes --namespace kafka --create-namespace

kafka-cluster:
	kubectl kustomize cluster | kubectl apply -f -

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
