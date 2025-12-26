#!/bin/bash
# filepath: /get-urls.sh

echo "🔍 Getting your deployment URLs..."

cd infra/environments/dev

if [ -f "terraform.tfstate" ]; then
    echo ""
    echo "📋 Your URLs:"
    echo "🌐 Website URL (for README): $(terraform output -raw website_url 2>/dev/null || echo 'Not deployed yet')"
    echo "⚡ API URL: $(terraform output -raw api_url 2>/dev/null || echo 'Not deployed yet')"
    echo "🪣 S3 Bucket: $(terraform output -raw s3_bucket_name 2>/dev/null || echo 'Not deployed yet')"
    echo ""
    echo "✅ Update your README with the Website URL above!"
else
    echo "❌ No terraform state found. Deploy first with 'terraform apply'"
fi