.PHONY: remote-kafka-client

default: remote-kafka-client

remote-kafka-client:
	kubectl get secret root-secret -n cert-manager -o jsonpath='{.data.tls\.crt}' | base64 --decode > certs/ca.crt
	kubectl get secret root-secret -n cert-manager -o jsonpath='{.data.tls\.key}' | base64 --decode > certs/ca.key
	openssl pkcs12 -export -out certs/ca.p12 -inkey certs/ca.key -in certs/ca.crt -name "kafka-cluster-ca" -password pass:supers1cret0
	chmod 644 certs/ca.p12
	docker compose up -d