package aws.compliance

# Require specific tags
deny[res] {
  input.resource_type in ["aws_instance", "aws_s3_bucket", "aws_db_instance"]
  not input.config.tags.Environment
  res := {
    "address": input.address,
    "rule": "aws.compliance.required_tags",
    "severity": "medium",
    "message": sprintf("Resource %s missing required tag: Environment", [input.address])
  }
}

deny[res] {
  input.resource_type in ["aws_instance", "aws_s3_bucket", "aws_db_instance"]
  not input.config.tags.Owner
  res := {
    "address": input.address,
    "rule": "aws.compliance.required_tags",
    "severity": "medium",
    "message": sprintf("Resource %s missing required tag: Owner", [input.address])
  }
}

# Require backup retention for databases
deny[res] {
  input.resource_type == "aws_db_instance"
  input.config.backup_retention_period < 7
  res := {
    "address": input.address,
    "rule": "aws.compliance.backup_retention",
    "severity": "medium",
    "message": sprintf("RDS instance %s backup retention period should be at least 7 days", [input.name])
  }
}