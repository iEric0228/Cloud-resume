# ============================================================
# backend.hcl — Partial S3 backend configuration for dev
#
# Run `scripts/bootstrap-state.sh` first to create the bucket
# and table, then run:
#   terraform init -backend-config=backend.hcl
#
# The `key` is intentionally NOT in this file so that the same
# backend.hcl pattern can be reused across environments by
# varying the key in CI (see .github/workflows/CI-CD.yaml).
# ============================================================

bucket         = "cloud-resume-tfstate-REPLACE_WITH_ACCOUNT_ID"
key            = "dev/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "cloud-resume-tfstate-lock"
