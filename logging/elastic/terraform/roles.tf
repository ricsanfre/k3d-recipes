# Locals
# This local variable `roles` defines the roles to be created in Elasticsearch. 
# The user definitions are read from JSON files in the "roles" directory.
# Each JSON file should contain the role's description, cluster privileges, index privileges and application privileges.

# JSON structure is the same payload required by the Elasticsearch API for role creation
#    ref: https://www.elastic.co/docs/api/doc/elasticsearch/operation/operation-security-put-role

# File name indicates the role name, and the content of the file should be a JSON object with the following structure:

# {
#   "description" : "Role description",
#   "cluster" : [ "cluster_privilege1", "cluster_privilege2" ],
#   "indices" : [
#     {
#       "names" : [ "index1", "index2" ],
#       "privileges" : [ "index_privilege1", "index_privilege2" ]
#     },
#     {
#       "names" : [ "index3" ],
#       "privileges" : [ "index_privilege3", "index_privilege4" ]
#     }
#   ],
#   "applications" : [
#     {
#       "application" : "myapp",
#       "privileges" : [ "admin", "read" ],
#       "resources" : [ "*" ]
#     }
#   ],
#   "metadata" : {
#     "key1" : "value1",
#     "key2" : "value2"
#   }
# }

# `roles` local variable is a map of objects, where the key is the name of the file (role name) and the value is an object containing the json content of the file

locals {
  json_role_files = fileset(path.module, "roles/*.json")
  roles           = { for f in local.json_role_files : regex("^(.+/)*(.+)\\.(.+)$", f)[1] => jsondecode(file("${path.module}/${f}")) }
}

# Resources
resource "elasticstack_elasticsearch_security_role" "roles" {
  for_each = local.roles

  name        = each.key
  description = each.value.description
  cluster     = each.value.cluster

  dynamic "indices" {
    for_each = each.value.indices
    content {
      names      = indices.value.names
      privileges = indices.value.privileges
    }
  }

  dynamic "applications" {
    for_each = each.value.applications
    content {
      application = applications.value.application
      privileges  = applications.value.privileges
      resources   = applications.value.resources
    }
  }

  metadata = each.value.metadata != null ? jsonencode(each.value.metadata) : null
}


# Outputs
output "roles" {
  value = elasticstack_elasticsearch_security_role.roles
}