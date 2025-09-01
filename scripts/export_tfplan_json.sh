#!/usr/bin/env bash
set -euo pipefail

# Export Terraform plan to JSON format
# Usage: ./export_tfplan_json.sh [plan_file] [json_file]

BIN_PATH="${1:-terraform/tfplan.bin}"
JSON_PATH="${2:-terraform/tfplan.json}"

if [ ! -f "$BIN_PATH" ]; then
    echo "Error: Terraform plan file not found: $BIN_PATH"
    exit 1
fi

echo "Exporting Terraform plan to JSON..."
terraform show -json "$BIN_PATH" > "$JSON_PATH"

echo "Plan exported to: $JSON_PATH"
echo "File size: $(wc -c < "$JSON_PATH") bytes"
