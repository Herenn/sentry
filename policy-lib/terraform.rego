package terraform

# Helper functions for Terraform plan analysis

# Get all resources of a specific type
resources_by_type(resource_type) = resources {
  resources := [resource | 
    resource := input.planned_values.root_module.resources[_]
    resource.type == resource_type
  ]
}

# Get all resource changes of a specific type
resource_changes_by_type(resource_type) = changes {
  changes := [change |
    change := input.resource_changes[_]
    change.type == resource_type
  ]
}

# Check if a resource has a specific tag
has_tag(resource, tag_name) {
  resource.values.tags[tag_name]
}

# Check if a resource has all required tags
has_required_tags(resource, required_tags) {
  count([tag | 
    tag := required_tags[_]
    has_tag(resource, tag)
  ]) == count(required_tags)
}