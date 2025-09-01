package digitalocean.compliance

# Require specific tags for all resources
deny[res] {
  input.resource_type in [
    "digitalocean_droplet", 
    "digitalocean_database_cluster",
    "digitalocean_spaces_bucket",
    "digitalocean_loadbalancer"
  ]
  not input.config.tags
  res := {
    "address": input.address,
    "rule": "digitalocean.compliance.tags_required",
    "severity": "medium",
    "message": sprintf("Resource %s must have tags", [input.address])
  }
}

deny[res] {
  input.resource_type in [
    "digitalocean_droplet", 
    "digitalocean_database_cluster",
    "digitalocean_spaces_bucket",
    "digitalocean_loadbalancer"
  ]
  input.config.tags
  not input.config.tags.environment
  res := {
    "address": input.address,
    "rule": "digitalocean.compliance.environment_tag_required",
    "severity": "medium",
    "message": sprintf("Resource %s missing required tag: environment", [input.address])
  }
}

deny[res] {
  input.resource_type in [
    "digitalocean_droplet", 
    "digitalocean_database_cluster",
    "digitalocean_spaces_bucket",
    "digitalocean_loadbalancer"
  ]
  input.config.tags
  not input.config.tags.project
  res := {
    "address": input.address,
    "rule": "digitalocean.compliance.project_tag_required",
    "severity": "medium",
    "message": sprintf("Resource %s missing required tag: project", [input.address])
  }
}

# Require specific regions for compliance
deny[res] {
  input.resource_type in [
    "digitalocean_droplet", 
    "digitalocean_database_cluster"
  ]
  not input.config.region in ["nyc1", "nyc3", "ams3", "sgp1", "lon1", "fra1"]
  res := {
    "address": input.address,
    "rule": "digitalocean.compliance.approved_regions",
    "severity": "medium",
    "message": sprintf("Resource %s must use approved regions", [input.address])
  }
}

# Require VPC for production resources
deny[res] {
  input.resource_type == "digitalocean_droplet"
  input.config.tags[_] == "environment:production"
  not input.config.vpc_uuid
  res := {
    "address": input.address,
    "rule": "digitalocean.compliance.production_vpc_required",
    "severity": "high",
    "message": sprintf("Production droplet %s must be in a VPC", [input.name])
  }
}

# Enforce naming conventions
deny[res] {
  input.resource_type in [
    "digitalocean_droplet", 
    "digitalocean_database_cluster"
  ]
  not regex.match("^[a-z][a-z0-9-]*[a-z0-9]$", input.config.name)
  res := {
    "address": input.address,
    "rule": "digitalocean.compliance.naming_convention",
    "severity": "low",
    "message": sprintf("Resource %s name should follow kebab-case convention", [input.address])
  }
}