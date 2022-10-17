docker run -p 24224:24224 --rm -v $(pwd)/fluentd:/fluentd/etc fluent/fluentd:edge-debian -c /fluentd/etc/fluentd.conf
