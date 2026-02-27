#!/usr/bin/env bash
# get-urls.sh — Print live deployment URLs from Terraform state
set -euo pipefail

INFRA_DIR="infrastructure/environments/dev"

if [ ! -d "${INFRA_DIR}/.terraform" ]; then
  echo "No Terraform state found. Run 'terraform init && terraform apply' first."
  exit 1
fi

cd "${INFRA_DIR}"
echo ""
echo "Website:     $(terraform output -raw website_url)"
echo "CloudFront:  https://$(terraform output -raw cloudfront_domain)"
echo "API:         $(terraform output -raw api_url)"
echo "S3 Bucket:   $(terraform output -raw s3_bucket_name)"
echo ""
