package digitalocean.security

# Deny droplets without private networking
deny[res] {
  input.resource_type == "digitalocean_droplet"
  not input.config.private_networking
  res := {
    "address": input.address,
    "rule": "digitalocean.security.private_networking_required",
    "severity": "medium",
    "message": sprintf("Droplet %s should enable private networking", [input.name])
  }
}

# Require monitoring for production droplets
deny[res] {
  input.resource_type == "digitalocean_droplet"
  input.config.tags[_] == "environment:production"
  not input.config.monitoring
  res := {
    "address": input.address,
    "rule": "digitalocean.security.monitoring_required",
    "severity": "medium",
    "message": sprintf("Production droplet %s must enable monitoring", [input.name])
  }
}

# Deny public Spaces (object storage)
deny[res] {
  input.resource_type == "digitalocean_spaces_bucket"
  input.config.acl == "public-read"
  res := {
    "address": input.address,
    "rule": "digitalocean.security.no_public_spaces",
    "severity": "high",
    "message": sprintf("Spaces bucket %s should not be public", [input.name])
  }
}

deny[res] {
  input.resource_type == "digitalocean_spaces_bucket"
  input.config.acl == "public-read-write"
  res := {
    "address": input.address,
    "rule": "digitalocean.security.no_public_spaces",
    "severity": "critical",
    "message": sprintf("Spaces bucket %s allows public write access", [input.name])
  }
}

# Require backups for database clusters
deny[res] {
  input.resource_type == "digitalocean_database_cluster"
  not input.config.backup_restore.backup_hour
  res := {
    "address": input.address,
    "rule": "digitalocean.security.database_backup_required",
    "severity": "high",
    "message": sprintf("Database cluster %s should enable automated backups", [input.name])
  }
}

# Require encryption for database clusters
deny[res] {
  input.resource_type == "digitalocean_database_cluster"
  not input.config.storage_size_mib
  input.config.engine != "redis"  # Redis doesn't support encryption at rest
  res := {
    "address": input.address,
    "rule": "digitalocean.security.database_encryption_recommended",
    "severity": "medium",
    "message": sprintf("Database cluster %s should consider encryption at rest", [input.name])
  }
}

# Warn about small droplet sizes in production
warn[res] {
  input.resource_type == "digitalocean_droplet"
  input.config.tags[_] == "environment:production"
  input.config.size in ["s-1vcpu-1gb", "s-1vcpu-2gb"]
  res := {
    "address": input.address,
    "rule": "digitalocean.security.production_sizing",
    "severity": "low",
    "message": sprintf("Production droplet %s uses small size, consider scaling up", [input.name])
  }
}