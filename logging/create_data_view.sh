curl -u elastic:${ELASTIC_PASS} \
 -X POST https://${KIBANA_URL}:${KIBANA_PORT}/api/data_views/data_view \
 -H 'Content-Type: application/json; Elastic-Api-Version=2023-10-31' \
 -H 'kbn-xsrf: string' \
 -d '
{ 
  "data_view": {
    "name": "fluentd",
    "title": "fluentd-*",
    "timeFieldName": "@timestamp"
  }
}
'
