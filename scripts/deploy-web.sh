#!/bin/bash
set -e

echo "🚀 Deploying website locally..."

cd infra/environments/dev

# Get outputs
S3_BUCKET=$(terraform output -raw s3_bucket_name)
API_URL=$(terraform output -raw api_url)
WEBSITE_URL=$(terraform output -raw website_url)

cd ../../../

# Update API URL
sed -i.bak "s|REPLACE_WITH_API_URL|$API_URL|g" ./website/js/visitor-counter.js

# Upload files
aws s3 sync ./website/ s3://$S3_BUCKET/ --delete
aws s3 cp ./website/index.html s3://$S3_BUCKET/index.html --content-type "text/html"
aws s3 cp ./website/css/styles.css s3://$S3_BUCKET/css/styles.css --content-type "text/css"
aws s3 cp ./website/js/visitor-counter.js s3://$S3_BUCKET/js/visitor-counter.js --content-type "application/javascript"

# Restore original
mv ./website/js/visitor-counter.js.bak ./website/js/visitor-counter.js

echo "Website deployed: $WEBSITE_URL"


#aws s3 cp website/index.html s3://$S3_BUCKET/index.html --content-type "text/html"
#aws s3 cp website/css/styles.css s3://$S3_BUCKET/css/styles.css --content-type "text/css"
