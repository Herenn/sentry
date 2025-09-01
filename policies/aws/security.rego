package aws.security

# Deny public S3 buckets
deny[res] {
  input.resource_type == "aws_s3_bucket"
  input.config.acl == "public-read"
  res := {
    "address": input.address,
    "rule": "aws.security.no_public_s3",
    "severity": "high",
    "message": sprintf("S3 bucket %s is public", [input.name])
  }
}

deny[res] {
  input.resource_type == "aws_s3_bucket"
  input.config.acl == "public-read-write"
  res := {
    "address": input.address,
    "rule": "aws.security.no_public_s3",
    "severity": "critical",
    "message": sprintf("S3 bucket %s allows public write access", [input.name])
  }
}

# Require encryption on RDS instances
deny[res] {
  input.resource_type == "aws_db_instance"
  not input.config.storage_encrypted
  res := {
    "address": input.address,
    "rule": "aws.security.rds_encryption_required",
    "severity": "critical",
    "message": sprintf("RDS instance %s has storage_encrypted=false", [input.name])
  }
}

# Deny unrestricted SSH access
deny[res] {
  input.resource_type == "aws_security_group"
  rule := input.config.ingress[_]
  rule.from_port == 22
  rule.to_port == 22
  rule.protocol == "tcp"
  "0.0.0.0/0" in rule.cidr_blocks
  res := {
    "address": input.address,
    "rule": "aws.security.no_ssh_from_anywhere",
    "severity": "high", 
    "message": sprintf("Security group %s allows SSH from anywhere", [input.name])
  }
}

# Require HTTPS for load balancers
deny[res] {
  input.resource_type == "aws_lb_listener"
  input.config.protocol == "HTTP"
  input.config.port == "443"
  res := {
    "address": input.address,
    "rule": "aws.security.require_https",
    "severity": "medium",
    "message": sprintf("Load balancer listener %s should use HTTPS", [input.name])
  }
}

# Require versioning on S3 buckets
warn[res] {
  input.resource_type == "aws_s3_bucket"
  not input.config.versioning
  res := {
    "address": input.address,
    "rule": "aws.security.s3_versioning_recommended",
    "severity": "low",
    "message": sprintf("S3 bucket %s should enable versioning", [input.name])
  }
}