#!/usr/bin/env bash
# publish-frontend.sh — inject the API URL, sync the static site to S3 with
# correct content types and cache headers, then invalidate CloudFront.
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
COUNTER_JS="${FRONTEND_DIR}/utils/visitor-counter.js"

echo "Injecting API URL into visitor-counter.js..."
cp "${COUNTER_JS}" "${COUNTER_JS}.bak"
# Restore the original (uninjected) file on exit so the working tree stays clean.
trap 'mv -f "${COUNTER_JS}.bak" "${COUNTER_JS}" 2>/dev/null || true' EXIT
sed "s|REPLACE_WITH_API_URL|${API_URL}|g" "${COUNTER_JS}.bak" > "${COUNTER_JS}"

if grep -q "REPLACE_WITH_API_URL" "${COUNTER_JS}"; then
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

aws s3 cp "${FRONTEND_DIR}/styles/styles.css" "s3://${S3_BUCKET}/styles/styles.css" \
  --content-type "text/css; charset=utf-8" \
  --cache-control "public, max-age=31536000"

aws s3 cp "${COUNTER_JS}" "s3://${S3_BUCKET}/utils/visitor-counter.js" \
  --content-type "text/javascript; charset=utf-8" \
  --cache-control "public, max-age=300"

if [[ -f "${FRONTEND_DIR}/utils/animation.js" ]]; then
  aws s3 cp "${FRONTEND_DIR}/utils/animation.js" "s3://${S3_BUCKET}/utils/animation.js" \
    --content-type "text/javascript; charset=utf-8" \
    --cache-control "public, max-age=31536000"
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
