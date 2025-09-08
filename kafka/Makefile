.PHONY: all clean base helm-setup strimzi-operator-install confluent-operator-install cnpg-install kafka-cluster schema-registry kafka-clients kafka-producer kafka-consumer kafdrop apicurio-operator apicurio-registry remote-kafka-client remote-kafka-producer remote-kafka-consumer kafka-avro-clients kafka-avro-producer

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
	helm repo add bitnami https://charts.bitnami.com/bitnami
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

kafka-cluster:
	kubectl kustomize cluster | kubectl apply -f -

kafdrop:
	kubectl kustomize kafdrop | kubectl apply -f -

kafka-clients:
	kubectl run kafka-clients --restart='Never' --image quay.io/strimzi/kafka:0.47.0-kafka-4.0.0 --namespace kafka --command -- sleep infinity
	kubectl cp clients/properties/producer.properties kafka/kafka-clients:/tmp/producer.properties
	kubectl cp clients/properties/consumer.properties kafka/kafka-clients:/tmp/consumer.properties

kafka-producer:
	kubectl exec -it kafka-clients --namespace kafka -- bin/kafka-console-producer.sh \
	--producer.config clients/tmp/producer.properties \
	--bootstrap-server cluster-kafka-bootstrap:9092 \
	--topic test-topic

kafka-consumer:
	kubectl exec -it kafka-clients --namespace kafka -- bin/kafka-console-consumer.sh \
	--consumer.config clients/tmp/consumer.properties \
	--bootstrap-server cluster-kafka-bootstrap:9092 \
	--topic test-topic \
	--group test-consumer-group --from-beginning

remote-kafka-client:
	cd clients && $(MAKE) $@

remote-kafka-producer:
	docker exec -it kafka-client bin/kafka-console-producer.sh \
	--producer.config /tmp/properties/producer_ssl.properties \
	--bootstrap-server kafka-bootstrap.local.test:443 \
	--topic test-topic

remote-kafka-consumer:
	docker exec -it kafka-client bin/kafka-console-consumer.sh \
	--consumer.config /tmp/properties/consumer_ssl.properties \
	--bootstrap-server kafka-bootstrap.local.test:443 \
	--topic test-topic \
	--group test-consumer-group --from-beginning

remote-kafka-command:
	docker exec -it kafka-client bin/command.sh \
	--config /tmp/properties/admin_ssl.properties \
	--bootstrap-server kafka-bootstrap.local.test:443 \

show-kafka-acls:
	docker exec -it kafka-client bin/kafka-acls.sh \
	--command-config /tmp/properties/admin_ssl.properties \
	--bootstrap-server kafka-bootstrap.local.test:443 \
	--list	

show-kafka-topics:
	docker exec -it kafka-client bin/kafka-topics.sh \
	--command-config /tmp/properties/admin_ssl.properties \
	--bootstrap-server kafka-bootstrap.local.test:443 \
	--list

schema-registry:
	kubectl kustomize schema-registry | kubectl apply -f -

schema-registry-bitnami:
	helm upgrade --install schema-registry bitnami/schema-registry -f schema-registry/schema-registry-bitnami-values.yaml --namespace kafka

apicurio-operator:
	curl -sSL "https://raw.githubusercontent.com/Apicurio/apicurio-registry/v3.0.12/operator/install/install.yaml" | sed "s/PLACEHOLDER_NAMESPACE/kafka/g" | kubectl -n kafka apply -f -

apicurio-db:
	kubectl kustomize apicurio/db | kubectl apply -f -
apicurio-registry:
	kubectl kustomize apicurio/registry | kubectl apply -f -

kafka-avro-producer:
	docker exec -it kafka-client-avro python3 avro_producer.py \
	-b kafka-bootstrap.local.test:443 \
	-s http://apicurio-app.local.test/apis/ccompat/v7 \
	-t test-topic \
	-m SCRAM-SHA-512 \
	--tls true \
	--cacert /tmp/certs/ca.crt \
	--user producer \
	--password supers1cret0

kafka-avro-consumer:
	docker exec -it kafka-client-avro python3 avro_consumer.py \
	-b kafka-bootstrap.local.test:443 \
	-s http://apicurio-app.local.test/apis/ccompat/v7 \
	-t test-topic \
	-m SCRAM-SHA-512 \
	-g test-consumer-group \
	--tls true \
	--cacert /tmp/certs/ca.crt \
	--user consumer \
	--password s1cret0

kafka-avro-producer-2:
	docker exec -it kafka-client-avro python3 avro_producer.py \
	-b kafka-bootstrap.local.test:443 \
	-s https://schema-registry.local.test \
	-su client \
	-sp s1cret0 \
	-t test-topic \
	-m SCRAM-SHA-512 \
	--tls true \
	--cacert /tmp/certs/ca.crt \
	--user producer \
	--password supers1cret0

kafka-avro-consumer-2:
	docker exec -it kafka-client-avro python3 avro_consumer.py \
	-b kafka-bootstrap.local.test:443 \
	-s https://schema-registry.local.test  \
	-su client \
	-sp s1cret0 \
	-t test-topic \
	-m SCRAM-SHA-512 \
	-g test-consumer-group \
	--tls true \
	--cacert /tmp/certs/ca.crt \
	--user consumer \
	--password s1cret0