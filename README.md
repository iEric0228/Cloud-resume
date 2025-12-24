# Cloud Resume – Automated Deployment

## Overview
Static resume site deployed on AWS using CI/CD.

## Architecture
- S3 for storage
- CloudFront for CDN
- GitHub Actions for deployment

## Deployment Flow
1. Push code to GitHub
2. GitHub Actions builds site
3. Files synced to S3
4. CloudFront cache invalidated

## Security
- S3 bucket is private
- Access via CloudFront OAC
- AWS credentials stored in GitHub Secrets
