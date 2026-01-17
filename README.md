# Cloud Resume Challenge - AWS Serverless Portfolio

> **A modern, serverless resume website demonstrating cloud architecture, DevOps practices, and full-stack development skills.**

[![Deploy Status](https://github.com/iEric0228/Cloud-resume/workflows/☁️%20Cloud%20Resume%20CI/CD/badge.svg)](https://github.com/iEric0228/Cloud-resume/actions)
[![AWS](https://img.shields.io/badge/AWS-FF9900?style=flat-square&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=flat-square&logo=terraform&logoColor=white)](https://terraform.io/)
[![Infrastructure](https://img.shields.io/badge/Infrastructure-as%20Code-blue?style=flat-square)]()

**Live Demo:** [Coming Soon - Deploy on Demand](https://github.com/iEric0228/Cloud-resume#-quick-start)

---

## Architecture Overview

This project implements a **serverless, highly-available resume website** with real-time visitor tracking, demonstrating modern cloud architecture patterns and DevOps best practices.

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Visitors      │───▶│   CloudFront     │───▶│   S3 Bucket     │
│   (Global)      │    │   (Global CDN)   │    │ (Static Website)│
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │   API Gateway    │───▶│ Lambda Function │
                       │  (RESTful API)   │    │ (Python Runtime)│
                       └──────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │   DynamoDB      │
                                               │ (Visitor Count) │
                                               └─────────────────┘
```

### **Key Features**

- **erverless Architecture** - Zero server management, infinite scalability
- **Global CDN** - Sub-second load times worldwide via CloudFront
- **Real-time Analytics** - Live visitor counter with DynamoDB persistence
- **Security First** - HTTPS everywhere, IAM roles, CORS policies
- **Cost Optimized** - Pay-per-use pricing, ~$1-2/month operational cost
- **CI/CD Pipeline** - Automated testing, deployment, and cleanup
- **Infrastructure as Code** - 100% Terraform, version controlled
- **Responsive Design** - Mobile-first, accessible UI/UX

---

## Technology Stack

### **Frontend**
- **HTML5/CSS3** - Semantic markup, modern styling
- **Vanilla JavaScript** - No frameworks, optimized performance
- **Responsive Design** - Mobile-first approach

### **Backend & Infrastructure**
- **AWS Lambda** - Serverless compute (Python 3.9)
- **API Gateway** - RESTful API with CORS
- **DynamoDB** - NoSQL database, on-demand billing
- **S3** - Static website hosting
- **CloudFront** - Global content delivery network
- **Route 53** - DNS management (optional)

### **DevOps & Automation**
- **Terraform** - Infrastructure as Code
- **GitHub Actions** - CI/CD pipeline
- **AWS OIDC** - Keyless authentication
- **Automated Testing** - Integration and performance tests

---

## Quick Start

### **Prerequisites**
- AWS Account with appropriate permissions
- GitHub account
- Terraform >= 1.5.0
- AWS CLI configured

### **1. Clone & Setup**
```bash
git clone https://github.com/iEric0228/Cloud-resume.git
cd Cloud-resume

# Configure your AWS credentials
aws configure
```

### **2. Deploy Infrastructure**
```bash
cd infra/environments/dev
terraform init
terraform apply
```

### **3. Upload Website**
```bash
# Get bucket name from Terraform output
BUCKET=$(terraform output -raw s3_bucket_name)

# Upload website files
aws s3 sync ../../../website/ s3://$BUCKET/
```

### **4. Access Your Resume**
```bash
# Get your website URL
terraform output website_url
```

---

## CI/CD Pipeline

### **Automated Workflows**

The project includes a sophisticated CI/CD pipeline that demonstrates enterprise DevOps practices:

#### **Pull Request Validation**
- Terraform syntax and formatting validation
- Website file structure verification  
- Infrastructure plan generation
- Automatic branch cleanup after merge

#### **Deployment Pipeline**
- Infrastructure provisioning via Terraform
- Website deployment to S3/CloudFront
- Integration testing (website + API)
- Cost-optimized cleanup options

#### **Cost Management**
```yaml
Deploy Modes:
  • deploy-test-destroy: $0.00 (auto-cleanup after testing)
  • deploy-test-keep: ~$1-2/month (portfolio mode)
  • destroy-only: Cleanup existing resources
```

### **Usage Examples**

```bash
# Development testing (zero cost)
gh workflow run "Cloud Resume CI/CD" \
  --field action=deploy-test-destroy \
  --field keep_alive_hours=2

# Portfolio deployment (keep running)
gh workflow run "Cloud Resume CI/CD" \
  --field action=deploy-test-keep \
  --field keep_alive_hours=720  # 30 days
```

---

## Performance & Monitoring

### **Performance Metrics**
- **Website Load Time:** < 2 seconds globally
- **API Response Time:** < 500ms average
- **Availability:** 99.9%+ (AWS SLA)
- **SSL Grade:** A+ (SSL Labs)

### **Monitoring Stack**
- **CloudWatch** - Metrics and logging
- **Lambda Insights** - Performance monitoring
- **X-Ray** - Distributed tracing (optional)
- **Cost Explorer** - Expense tracking

---

## Cost Analysis

### **Monthly Operational Costs**
```
Service              | Usage           | Cost/Month
---------------------|-----------------|------------
S3 Standard         | 1GB storage     | $0.02
CloudFront          | 1GB transfer    | $0.09
Lambda              | 1M invocations  | $0.20
API Gateway         | 1M requests     | $1.00
DynamoDB            | On-demand       | $0.25
Route 53 (optional) | 1 hosted zone   | $0.50
---------------------|-----------------|------------
Total               |                 | ~$2.06/month
```

*Actual costs may be lower due to AWS Free Tier eligibility.*

---

## Security Features

### **Implementation**
- **HTTPS Everywhere** - SSL/TLS encryption
- **IAM Roles** - Principle of least privilege
- **CORS Policies** - Controlled API access
- **Security Headers** - XSS, CSRF protection
- **Input Validation** - API parameter sanitization
- **VPC Isolation** - Network security (optional)

### **Compliance**
- **OWASP Top 10** - Security best practices
- **AWS Well-Architected** - Framework compliance
- **GDPR Considerations** - Privacy by design

---

## Testing Strategy

### **Automated Tests**
- **Infrastructure Validation** - Terraform fmt, validate, plan
- **Website Accessibility** - HTTP response codes, load times
- **API Functionality** - Visitor counter increment/decrement
- **Performance Testing** - Load time thresholds
- **Security Scanning** - Basic vulnerability checks

### **Manual Testing Checklist**
- [ ] Website loads on desktop/mobile
- [ ] Visitor counter increments correctly
- [ ] All links and navigation work
- [ ] SSL certificate valid
- [ ] Page load time < 3 seconds

---

## Future Enhancements

### **Phase 2 Features**
- [ ] **Custom Domain** - Professional branding
- [ ] **Contact Form** - SES integration
- [ ] **Blog Section** - Technical writing showcase
- [ ] **Analytics Dashboard** - Visitor insights
- [ ] **A/B Testing** - Resume optimization

### **Advanced Integrations**
- [ ] **LinkedIn API** - Dynamic experience sync
- [ ] **GitHub API** - Live repository stats
- [ ] **Monitoring Dashboard** - CloudWatch metrics
- [ ] **Mobile App** - React Native version

## Project Journey

### **Learning Outcomes**
This project demonstrates proficiency in:

- **Cloud Architecture** - AWS serverless services
- **Infrastructure as Code** - Terraform best practices  
- **DevOps** - CI/CD pipelines, automation
- **Security** - AWS IAM, HTTPS, secure coding
- **Cost Optimization** - AWS billing, resource management
- **Monitoring** - CloudWatch, performance tuning
- **Full-Stack Development** - Frontend + Backend + Infrastructure

### **Technical Challenges Solved**
- Serverless architecture design and implementation
- Cross-origin resource sharing (CORS) configuration
- CloudFront distribution with custom origins
- DynamoDB NoSQL data modeling
- GitHub Actions OIDC authentication
- Terraform state management and modules
- Cost-optimized auto-scaling infrastructure

---

## Resources & References

### **AWS Documentation**
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Serverless Application Lens](https://docs.aws.amazon.com/wellarchitected/latest/serverless-applications-lens/)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)

### **Tools & Technologies**
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)

---

## Author

**Eric Chiu**
- Portfolio: [Deploy on Demand](https://github.com/iEric0228/Cloud-resume#-quick-start)
- LinkedIn: [Eric Chiu](https://www.linkedin.com/in/eric-chiu-a610553a3/)  
- GitHub: [@iEric0228](https://github.com/iEric0228)
- Email: ericchiu0228@gmail.com
