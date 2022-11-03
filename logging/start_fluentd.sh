docker run -p 24224:24224 --rm -v $(pwd)/fluentd:/fluentd/etc ricsanfre/fluentd-aggregator:v1.15.2-debian-1.0 -c /fluentd/etc/fluentd.conf
