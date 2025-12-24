Developer (Git Push)
        |
        v
GitHub Repository
        |
        v
GitHub Actions (CI/CD)
        |
        |---> Build static site
        |---> Upload to S3
        |---> Invalidate CloudFront cache
        v
AWS S3 (Private Bucket)
        |
        v
CloudFront CDN
        |
        v
Public Internet (Your Resume Website)
