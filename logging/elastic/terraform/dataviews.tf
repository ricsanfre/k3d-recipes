# Resources
resource "elasticstack_kibana_data_view" "fluentd_view" {
  data_view = {
    name            = "fluentd-logs"
    title           = "fluentd-*"
    time_field_name = "@timestamp"
    namespaces      = ["default"]
  }
}

# Outputs
output "fluentd_data_view" {
  value = elasticstack_kibana_data_view.fluentd_view
}