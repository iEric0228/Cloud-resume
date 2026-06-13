#!/usr/bin/env bash
# deploy-web.sh — Local website deployment helper.
# Reads Terraform outputs, then delegates publishing to publish-frontend.sh.
# Run from the repository root.
set -euo pipefail

INFRA_DIR="infrastructure/environments/dev"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Reading Terraform outputs from ${INFRA_DIR}..."
cd "${REPO_ROOT}/${INFRA_DIR}"
export S3_BUCKET="$(terraform output -raw s3_bucket_name)"
export API_URL="$(terraform output -raw api_url)"
export CLOUDFRONT_ID="$(terraform output -raw cloudfront_distribution_id)"
WEBSITE_URL="$(terraform output -raw website_url)"

cd "${REPO_ROOT}"
bash "${SCRIPT_DIR}/publish-frontend.sh"

echo "Deployment complete: ${WEBSITE_URL}"
