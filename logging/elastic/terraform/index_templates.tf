locals {
  json_template_files = fileset(path.module, "templates/*.json")
  templates           = { for f in local.json_template_files : regex("^(.+/)*(.+)\\.(.+)$", f)[1] => jsondecode(file("${path.module}/${f}")) }
}


resource "elasticstack_elasticsearch_index_template" "index_templates" {
  for_each       = local.templates
  name           = each.key
  index_patterns = each.value.index_patterns

  template {
    settings = jsonencode(each.value.template.settings)
    mappings = jsonencode(each.value.template.mappings)
  }
}


# Outputs
output "index_templates" {
  value = elasticstack_elasticsearch_index_template.index_templates
}