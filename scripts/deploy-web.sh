#!/usr/bin/env bash
# deploy-web.sh — Local website deployment helper
# Reads Terraform outputs, injects API URL, syncs to S3, invalidates CloudFront cache.
set -euo pipefail

INFRA_DIR="infrastructure/environments/dev"
FRONTEND_DIR="frontend"

echo "Reading Terraform outputs from ${INFRA_DIR}..."
cd "${INFRA_DIR}"

S3_BUCKET=$(terraform output -raw s3_bucket_name)
API_URL=$(terraform output -raw api_url)
WEBSITE_URL=$(terraform output -raw website_url)
CF_ID=$(terraform output -raw cloudfront_distribution_id)

cd "../../.."

echo "Injecting API URL into visitor-counter.js..."
cp "${FRONTEND_DIR}/utils/visitor-counter.js" "${FRONTEND_DIR}/utils/visitor-counter.js.bak"
sed -i "s|REPLACE_WITH_API_URL|${API_URL}|g" "${FRONTEND_DIR}/utils/visitor-counter.js"

echo "Syncing website files to s3://${S3_BUCKET}..."
aws s3 sync "./${FRONTEND_DIR}/" "s3://${S3_BUCKET}/" \
  --delete \
  --cache-control "public, max-age=31536000" \
  --exclude "*.html"

# HTML: no-cache so users always get the latest
aws s3 cp "./${FRONTEND_DIR}/index.html" "s3://${S3_BUCKET}/index.html" \
  --content-type "text/html; charset=utf-8" \
  --cache-control "no-cache, no-store, must-revalidate"

echo "Restoring original visitor-counter.js..."
mv "${FRONTEND_DIR}/utils/visitor-counter.js.bak" "${FRONTEND_DIR}/utils/visitor-counter.js"

echo "Invalidating CloudFront cache (distribution: ${CF_ID})..."
aws cloudfront create-invalidation \
  --distribution-id "${CF_ID}" \
  --paths "/*" \
  --query 'Invalidation.Id' \
  --output text

echo "Deployment complete: ${WEBSITE_URL}"
