package utils

# Utility functions for policy evaluation

# Check if a CIDR allows access from anywhere
allows_public_access(cidr_blocks) {
  "0.0.0.0/0" in cidr_blocks
}

# Check if a port range includes a specific port
port_range_includes(from_port, to_port, target_port) {
  from_port <= target_port
  to_port >= target_port
}

# Get severity level as number for comparison
severity_level(severity) = level {
  severity_map := {
    "low": 1,
    "medium": 2,
    "high": 3,
    "critical": 4
  }
  level := severity_map[severity]
}

# Check if severity meets threshold
severity_meets_threshold(severity, threshold) {
  severity_level(severity) >= severity_level(threshold)
}