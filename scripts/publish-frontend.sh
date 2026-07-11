#!/usr/bin/env bash
# publish-frontend.sh — build the React frontend, inject the API URL, sync
# the static site to S3 with correct content types and cache headers, then
# invalidate CloudFront.
#
# Shared by the deploy workflow, the ephemeral test workflow, and deploy-web.sh
# so the publish logic lives in exactly one place.
#
# Required env: S3_BUCKET, API_URL
# Optional env: CLOUDFRONT_ID, FRONTEND_DIR (default: frontend)
set -euo pipefail

: "${S3_BUCKET:?S3_BUCKET is required}"
: "${API_URL:?API_URL is required}"
FRONTEND_DIR="${FRONTEND_DIR:-frontend}"
CONFIG_JS="${FRONTEND_DIR}/config.js"

echo "Building frontend (Vite outputs into ${FRONTEND_DIR}/)..."
npm --prefix web install
npm --prefix web run build

echo "Injecting API URL into config.js..."
sed -i.bak "s|REPLACE_WITH_API_URL|${API_URL}|g" "${CONFIG_JS}"
rm -f "${CONFIG_JS}.bak"
if grep -q "REPLACE_WITH_API_URL" "${CONFIG_JS}"; then
  echo "ERROR: API URL placeholder was not replaced" >&2
  exit 1
fi

echo "Syncing ${FRONTEND_DIR}/ to s3://${S3_BUCKET}/ ..."
aws s3 sync "${FRONTEND_DIR}/" "s3://${S3_BUCKET}/" --delete

# Explicit content types + cache headers on the actually-served paths.
# Correct MIME types are mandatory: CloudFront sends X-Content-Type-Options:
# nosniff, so a CSS/JS file served as text/plain would be blocked by the browser.
echo "Setting content types and cache headers..."
aws s3 cp "${FRONTEND_DIR}/index.html" "s3://${S3_BUCKET}/index.html" \
  --content-type "text/html; charset=utf-8" \
  --cache-control "no-cache, no-store, must-revalidate"

if [[ -f "${FRONTEND_DIR}/resume.html" ]]; then
  aws s3 cp "${FRONTEND_DIR}/resume.html" "s3://${S3_BUCKET}/resume.html" \
    --content-type "text/html; charset=utf-8" \
    --cache-control "no-cache, no-store, must-revalidate"
fi

# config.js carries the live API URL and must never be cached, or a stale
# REPLACE_WITH_API_URL / old endpoint could be served after a deploy.
aws s3 cp "${CONFIG_JS}" "s3://${S3_BUCKET}/config.js" \
  --content-type "text/javascript; charset=utf-8" \
  --cache-control "no-cache, no-store, must-revalidate"

# Vite fingerprints everything under assets/ by content hash, so these are
# safe to cache forever — a content change always produces a new filename.
if [[ -d "${FRONTEND_DIR}/assets" ]]; then
  aws s3 cp "${FRONTEND_DIR}/assets" "s3://${S3_BUCKET}/assets" \
    --recursive \
    --cache-control "public, max-age=31536000, immutable"
fi

if [[ -n "${CLOUDFRONT_ID:-}" ]]; then
  echo "Invalidating CloudFront distribution ${CLOUDFRONT_ID}..."
  aws cloudfront create-invalidation \
    --distribution-id "${CLOUDFRONT_ID}" \
    --paths "/*" \
    --query 'Invalidation.Id' \
    --output text
fi

echo "Frontend published to s3://${S3_BUCKET}/"
