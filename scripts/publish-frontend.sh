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
INDEX_HTML="${FRONTEND_DIR}/index.html"
COUNTER_JS="${FRONTEND_DIR}/utils/visitor-counter.js"
STYLES_CSS="${FRONTEND_DIR}/styles/styles.css"
ANIMATION_JS="${FRONTEND_DIR}/utils/animation.js"

# Short content hash for cache-busting (portable across macOS and Linux).
asset_version() {
  if command -v shasum >/dev/null 2>&1; then
    shasum "$1" | cut -c1-8
  else
    sha1sum "$1" | cut -c1-8
  fi
}

echo "Injecting API URL into visitor-counter.js..."
# Back up edited files OUTSIDE the synced dir so backups are never uploaded.
COUNTER_BACKUP="$(mktemp)"
cp "${COUNTER_JS}" "${COUNTER_BACKUP}"
INDEX_BACKUP="$(mktemp)"
cp "${INDEX_HTML}" "${INDEX_BACKUP}"
# Restore originals on exit so the working tree stays clean.
trap 'mv -f "${COUNTER_BACKUP}" "${COUNTER_JS}" 2>/dev/null || true; mv -f "${INDEX_BACKUP}" "${INDEX_HTML}" 2>/dev/null || true' EXIT

sed "s|REPLACE_WITH_API_URL|${API_URL}|g" "${COUNTER_BACKUP}" > "${COUNTER_JS}"
if grep -q "REPLACE_WITH_API_URL" "${COUNTER_JS}"; then
  echo "ERROR: API URL placeholder was not replaced" >&2
  exit 1
fi

# Cache-busting: append ?v=<content-hash> to the asset links in index.html.
# index.html is served no-cache, so returning visitors always get fresh HTML;
# the version query changes only when CSS/JS content changes, forcing the browser
# to re-fetch them even though they keep a long max-age. (visitor-counter.js is
# hashed AFTER URL injection so the version reflects the deployed content.)
echo "Adding cache-busting version queries to index.html..."
CSS_V="$(asset_version "${STYLES_CSS}")"
COUNTER_V="$(asset_version "${COUNTER_JS}")"
ANIMATION_V="$(asset_version "${ANIMATION_JS}")"
sed -e "s|styles/styles.css\"|styles/styles.css?v=${CSS_V}\"|g" \
    -e "s|utils/visitor-counter.js\"|utils/visitor-counter.js?v=${COUNTER_V}\"|g" \
    -e "s|utils/animation.js\"|utils/animation.js?v=${ANIMATION_V}\"|g" \
    "${INDEX_BACKUP}" > "${INDEX_HTML}"

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
