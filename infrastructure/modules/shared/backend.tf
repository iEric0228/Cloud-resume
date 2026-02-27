# Remote state is configured via backend.hcl in each environment directory.
# S3 bucket:      ericchiu-terraform-state
# DynamoDB table: terraform-state-lock
#
# To initialise locally:
#   cd infrastructure/environments/dev
#   terraform init -backend-config=backend.hcl
