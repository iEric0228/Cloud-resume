<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=180&section=header&text=Eric%20Chiu&fontSize=42&fontColor=fff&animation=twinkling&fontAlignY=32&desc=DevOps%20%7C%20Cloud%20Engineer%20%7C%20AWS%20Certified&descAlignY=55&descSize=18" width="100%"/>
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/eric-chiu-a610553a3)
[![Email](https://img.shields.io/badge/Email-EA4335?style=flat&logo=gmail&logoColor=white)](mailto:ericchiu0228@gmail.com)
[![Portfolio](https://img.shields.io/badge/Portfolio-000000?style=flat&logo=github&logoColor=white)](https://github.com/iEric0228)
![Profile Views](https://komarev.com/ghpvc/?username=iEric0228&color=blueviolet&style=flat)
[![Open to Work](https://img.shields.io/badge/Open%20to%20Work-28a745?style=flat&logo=checkmarx&logoColor=white)](mailto:ericchiu0228@gmail.com)
</div>

# Cloud Resume Challenge - AWS Serverless Portfolio

> **A modern, serverless resume website demonstrating cloud architecture, DevOps practices, and full-stack development skills.**

[![Deploy Status](https://github.com/iEric0228/Cloud-resume/workflows/☁️%20Cloud%20Resume%20CI/CD/badge.svg)](https://github.com/iEric0228/Cloud-resume/actions)
[![AWS](https://img.shields.io/badge/AWS-FF9900?style=flat-square&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=flat-square&logo=terraform&logoColor=white)](https://terraform.io/)
[![Infrastructure](https://img.shields.io/badge/Infrastructure-as%20Code-blue?style=flat-square)]()

**Live Site:** [https://ericchiu.page](https://ericchiu.page)

---

## Architecture Overview

This project implements a **serverless, highly-available resume website** with real-time visitor tracking, fully provisioned through Infrastructure as Code and deployed via a CI/CD pipeline.

```
                          ┌──────────────────┐
                          │   Route 53       │
          ericchiu.page──▶│  (DNS + Alias)   │
                          └────────┬─────────┘
                                   │
                                   ▼
                          ┌──────────────────┐      ┌─────────────────┐
┌────────────────┐        │   CloudFront     │─────▶│   S3 Bucket     │
│   Visitors     │──────▶ │   (Global CDN)   │      │  (Static Site)  │
│   (Global)     │        │  + ACM (HTTPS)   │      │  Private / OAC  │
└────────────────┘        └──────────────────┘      └─────────────────┘
                                   │
                                   ▼
                          ┌──────────────────┐      ┌─────────────────┐
                          │   API Gateway    │─────▶│ Lambda Function │
                          │   (HTTP API)     │      │ (Python 3.12)   │
                          └──────────────────┘      └────────┬────────┘
                                                             │
                                                             ▼
                                                    ┌─────────────────┐
                                                    │   DynamoDB      │
                                                    │ (Visitor Count) │
                                                    └─────────────────┘

           Terraform Remote State
           ┌──────────────────────┐
           │ S3 Bucket + DynamoDB │
           │    (State Locking)   │
           └──────────────────────┘
```

### Key Features

- **Serverless Architecture** - Zero server management, automatic scaling
- **Custom Domain** - HTTPS via ACM certificate + Route 53 DNS
- **Global CDN** - Sub-second load times worldwide via CloudFront
- **Real-time Visitor Counter** - Live visitor tracking with DynamoDB
- **Security First** - HTTPS everywhere, OAC for S3, IAM least privilege, CORS policies
- **CI/CD Pipeline** - Automated deploy, test, and teardown via GitHub Actions
- **Infrastructure as Code** - 100% Terraform with modular design
- **Remote State** - S3 backend with DynamoDB state locking

---

## Project Structure

```
Cloud-resume/
├── .github/
│   └── workflows/
│       └── CI-CD.yaml              # GitHub Actions pipeline
├── backend/
│   └── lambda/
│       └── handler.py              # Visitor counter Lambda (Python 3.12)
├── frontend/
│   ├── index.html                  # Resume page
│   ├── styles/
│   │   └── styles.css              # Stylesheet
│   └── utils/
│       ├── animation.js            # UI animations
│       └── visitor-counter.js      # API client for visitor counter
├── infrastructure/
│   ├── environments/
│   │   └── dev/
│   │       ├── main.tf             # Root module — wires all modules together
│   │       ├── variables.tf        # Environment variables
│   │       ├── outputs.tf          # Terraform outputs
│   │       └── backend.hcl         # Remote state config (local use)
│   └── modules/
│       ├── acm/                    # ACM certificate (DNS-validated)
│       ├── api-gateway/            # HTTP API + Lambda integration
│       ├── cloudfront/             # CDN + OAC + S3 bucket policy
│       ├── dynamodb/               # Visitor counter table
│       ├── lambda/                 # Function + IAM role/policies
│       ├── route53/                # DNS alias records + cert validation
│       └── s3/                     # Private bucket (encryption, CORS)
├── scripts/
│   ├── deploy-web.sh               # Manual website deploy helper
│   ├── get-urls.sh                 # Print Terraform outputs
│   └── validate.py                 # Validation utility
├── docs/                           # Architecture & design documentation
├── .gitignore
├── eslint.config.mjs
└── package.json
```

---

## Technology Stack

### Frontend
- **HTML5 / CSS3** - Semantic markup, responsive design
- **Vanilla JavaScript** - Animations and visitor counter API client

### Backend
- **AWS Lambda** - Serverless compute (Python 3.12)
- **API Gateway** - HTTP API with CORS
- **DynamoDB** - NoSQL database, on-demand (pay-per-request) billing

### Hosting & DNS
- **S3** - Private static file storage (no public access)
- **CloudFront** - Global CDN with Origin Access Control (OAC)
- **ACM** - SSL/TLS certificate (DNS-validated, auto-renewing)
- **Route 53** - DNS hosted zone with alias records

### DevOps & Automation
- **Terraform** (>= 1.6) - Infrastructure as Code with modular design
- **GitHub Actions** - CI/CD pipeline with OIDC authentication
- **AWS OIDC** - Keyless, short-lived credentials (no static access keys)
- **S3 + DynamoDB** - Remote state backend with locking

---

## Quick Start

### Prerequisites
- AWS Account with appropriate permissions
- GitHub account (for CI/CD)
- [Terraform](https://terraform.io/) >= 1.6
- [AWS CLI](https://aws.amazon.com/cli/) configured

### 1. Clone the Repository
```bash
git clone https://github.com/iEric0228/Cloud-resume.git
cd Cloud-resume
```

### 2. Bootstrap Remote State (one-time)

Before deploying infrastructure, create the S3 bucket and DynamoDB table that Terraform uses to store its state:

```bash
# Create the state bucket and lock table (run once)
aws s3api create-bucket --bucket <your-state-bucket> --region us-east-1
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### 3. Deploy Infrastructure

```bash
cd infrastructure/environments/dev

# Initialise with remote backend
terraform init \
  -backend-config="bucket=<your-state-bucket>" \
  -backend-config="key=cloud-resume/dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=terraform-state-lock"

terraform plan
terraform apply
```

### 4. Upload Website Files

```bash
# Get the bucket name from Terraform output
BUCKET=$(terraform output -raw s3_bucket_name)

# Sync frontend files to S3
aws s3 sync ../../../frontend/ s3://$BUCKET/

# Invalidate CloudFront cache
DIST_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"
```

### 5. Access Your Resume

```bash
terraform output website_url
```

---

## Custom Domain Setup

The project supports an optional custom domain via the `enable_custom_domain` variable.

| Variable | Default | Description |
|---|---|---|
| `enable_custom_domain` | `true` | Toggle custom domain (ACM + Route 53) |
| `domain_name` | `ericchiu.page` | Root domain for the website |

When `enable_custom_domain = true`, Terraform will:
1. Look up the existing Route 53 hosted zone for the domain
2. Create an ACM certificate and validate it via DNS
3. Create alias records (`domain.com` + `www.domain.com`) pointing to CloudFront

**Prerequisites for custom domain:**
1. Register your domain (any registrar)
2. Create a Route 53 hosted zone for the domain in AWS
3. Update your registrar's nameservers to the values from Route 53
4. Wait for DNS propagation (check with `dig NS yourdomain.com`)
5. Set `enable_custom_domain = true` and run `terraform apply`

When `enable_custom_domain = false`, the site is served from the default CloudFront domain (`d1234.cloudfront.net`).

---

## CI/CD Pipeline

### Workflow Overview

The GitHub Actions pipeline (`.github/workflows/CI-CD.yaml`) provides automated infrastructure management with three deploy modes:

| Mode | Description | Cost |
|---|---|---|
| `deploy-test-destroy` | Deploy, run tests, tear everything down | $0.00 |
| `deploy-test-keep` | Deploy, run tests, leave running | ~$0.50-1.00/month |
| `destroy-only` | Tear down existing resources | — |

### Pipeline Steps

1. **Checkout** code
2. **Configure AWS** credentials via OIDC (no static keys)
3. **Terraform init** with remote S3 backend
4. **Import** orphaned resources (IAM role, DynamoDB table) if needed
5. **Terraform plan + apply** infrastructure
6. **Deploy** frontend files to S3
7. **Invalidate** CloudFront cache
8. **Integration tests** - verify website and API responses
9. **Cleanup** - destroy resources (if `deploy-test-destroy` mode)

### Pull Request Validation
- `terraform validate` and `terraform fmt -check`
- Frontend file structure verification (`index.html`, `styles.css`, `visitor-counter.js`)

### Usage

```bash
# Development testing (zero cost - auto-destroys after tests)
gh workflow run "☁️ Cloud Resume CI/CD" \
  --field action=deploy-test-destroy \
  --field keep_alive_minutes=5

# Portfolio deployment (keep running)
gh workflow run "☁️ Cloud Resume CI/CD" \
  --field action=deploy-test-keep \
  --field keep_alive_minutes=5

# Tear down everything
gh workflow run "☁️ Cloud Resume CI/CD" \
  --field action=destroy-only
```

### Required GitHub Secrets / OIDC

The pipeline authenticates to AWS using **OpenID Connect** — no static AWS keys are stored in GitHub. You need:

1. An IAM OIDC identity provider for `token.actions.githubusercontent.com`
2. An IAM role with a trust policy that allows your GitHub repo to assume it
3. The role ARN configured in the workflow file

---

## Terraform Module Reference

| Module | Purpose | Key Resources |
|---|---|---|
| **s3** | Private static file bucket | S3 bucket, public access block, SSE, CORS |
| **cloudfront** | CDN with OAC | Distribution, OAC, S3 bucket policy |
| **acm** | SSL/TLS certificate | ACM certificate (DNS validation) |
| **route53** | DNS records | Alias records (A + AAAA), cert validation records |
| **lambda** | Visitor counter function | Lambda function, IAM role + policies |
| **api-gateway** | HTTP API | API Gateway, Lambda integration, CORS |
| **dynamodb** | Visitor count storage | DynamoDB table (on-demand billing) |

### Dependency Chain

```
data.route53_zone  --> looks up existing hosted zone
module.s3          --> no dependencies
module.dynamodb    --> no dependencies
module.lambda      --> dynamodb
module.api_gateway --> lambda
module.acm         --> (only when enable_custom_domain = true)
module.cloudfront  --> s3, route53 (when custom domain enabled)
module.route53     --> zone, acm, cloudfront (when custom domain enabled)
```

---

## Cost Estimate

For a low-traffic personal portfolio site:

| Service | Usage | Estimated Cost |
|---|---|---|
| Route 53 | 1 hosted zone | $0.50/month |
| S3 | < 1 GB storage | < $0.01/month |
| CloudFront | < 1 GB transfer | Free tier / < $0.01/month |
| Lambda | < 10k invocations | Free tier |
| API Gateway | < 10k requests | Free tier |
| DynamoDB | On-demand, minimal | Free tier |
| **Total** | | **~$0.50 - $1.00/month** |

Route 53 is the only guaranteed charge. Most other services fall within the AWS Free Tier for typical portfolio traffic.

The `deploy-test-destroy` CI/CD mode costs nothing — infrastructure is torn down after testing.

---

## Security

- **HTTPS everywhere** - CloudFront enforces `redirect-to-https`
- **Origin Access Control** - S3 bucket is fully private; only CloudFront can read objects
- **IAM least privilege** - Lambda role has only the DynamoDB permissions it needs
- **CORS policies** - API Gateway restricts origins to the website domain
- **No static AWS keys** - CI/CD uses OIDC for short-lived credentials
- **Encryption at rest** - S3 server-side encryption (AES-256)
- **Remote state locking** - DynamoDB prevents concurrent Terraform operations

---

## Author

**Eric Chiu**
- Website: [ericchiu.page](https://ericchiu.page)
- LinkedIn: [Eric Chiu](https://www.linkedin.com/in/eric-chiu-a610553a3/)
- GitHub: [@iEric0228](https://github.com/iEric0228)
- Email: ericchiu0228@gmail.com

