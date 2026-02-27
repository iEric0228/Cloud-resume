#!/usr/bin/env bash
# bootstrap-state.sh
# Creates the S3 bucket and DynamoDB table for Terraform remote state.
# Run this ONCE before your first `terraform init` in any environment.
#
# Usage: ./scripts/bootstrap-state.sh
set -euo pipefail

BOOTSTRAP_DIR="infrastructure/bootstrap"
DEV_DIR="infrastructure/environments/dev"

echo ""
echo "=== Step 1: Bootstrapping remote state infrastructure ==="
cd "${BOOTSTRAP_DIR}"
terraform init -input=false
terraform apply -auto-approve -input=false

# Capture outputs
STATE_BUCKET=$(terraform output -raw state_bucket_name)
LOCK_TABLE=$(terraform output -raw lock_table_name)
AWS_REGION="us-east-1"

cd "../../.."

echo ""
echo "=== Step 2: Writing backend.hcl for dev environment ==="
cat > "${DEV_DIR}/backend.hcl" <<HCLEOF
bucket         = "${STATE_BUCKET}"
key            = "dev/terraform.tfstate"
region         = "${AWS_REGION}"
encrypt        = true
dynamodb_table = "${LOCK_TABLE}"
HCLEOF

echo "Written: ${DEV_DIR}/backend.hcl"

echo ""
echo "=== Step 3: Initialising dev environment with remote backend ==="
cd "${DEV_DIR}"
terraform init -backend-config=backend.hcl -reconfigure -input=false

echo ""
echo "Remote state setup complete."
echo "  State bucket:  s3://${STATE_BUCKET}/dev/terraform.tfstate"
echo "  Lock table:    ${LOCK_TABLE}"
echo ""
echo "Next: cd ${DEV_DIR} && terraform plan"
