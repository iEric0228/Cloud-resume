# Cloud Resume Challenge - Infrastructure Architecture

## **Architecture Overview**

This project implements a modern, scalable cloud resume website using AWS services, following Infrastructure as Code (IaC) best practices with Terraform. The architecture demonstrates professional DevOps engineering skills with modular design, security best practices, and cost optimization.

## **Project Goals**

- **Serverless Architecture**: Fully managed services with automatic scaling
- **Cost Optimization**: Pay-per-use services minimizing operational costs
- **Security First**: Principle of least privilege and secure defaults
- **Professional Standards**: Modular, reusable, and maintainable code
- **CI/CD Integration**: Automated testing and deployment pipelines

## **High-Level Architecture**

```
┌─────────────────────────────────────────────────────────────────┐
│                        Internet Users                            │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                     CloudFront CDN                              │
│  • Global edge locations for fast content delivery              │
│  • HTTPS termination and security headers                       │
│  • Caching strategy for optimal performance                     │
└─────────────────────┬───────────────┬───────────────────────────┘
                      │               │
                      ▼               ▼
        ┌─────────────────────┐   ┌─────────────────────┐
        │    S3 Bucket        │   │   API Gateway       │
        │  Static Website     │   │   HTTP API          │
        │  • HTML/CSS/JS      │   │   • CORS enabled    │
        │  • Private bucket   │   │   • /count endpoint │
        │  • OAC security     │   └─────────┬───────────┘
        └─────────────────────┘             │
                                           ▼
                                ┌─────────────────────┐
                                │  Lambda Function    │
                                │  Visitor Counter    │
                                │  • Python 3.11     │
                                │  • Error handling   │
                                │  • Logging enabled  │
                                └─────────┬───────────┘
                                          │
                                          ▼
                                ┌─────────────────────┐
                                │   DynamoDB Table    │
                                │  Visitor Storage    │
                                │  • Pay-per-request  │
                                │  • Auto-scaling     │
                                │  • Atomic updates   │
                                └─────────────────────┘
```

## **Terraform Module Architecture**

### **Design Philosophy**

My infrastructure follows the **Single Responsibility Principle** - each module manages one AWS service with clear boundaries and interfaces.

```
infra/
├── modules/                    # Reusable infrastructure components
│   ├── s3/                    # Static website hosting
│   ├── cloudfront/            # CDN and security
│   ├── dynamodb/              # Data persistence layer
│   ├── lambda/                # Compute layer (visitor counter logic)
│   ├── api-gateway/           # API management layer
│   └── shared/                # Common configurations
├── environments/              # Environment-specific configurations
│   ├── dev/                   # Development environment
│   └── prod/                  # Production environment
└── .github/workflows/         # CI/CD automation
```

## **Module Specifications**

### **S3 Module** - Static Website Hosting
```hcl
Purpose: Secure static website hosting with CloudFront integration
Resources:
  - aws_s3_bucket: Website content storage
  - aws_s3_bucket_website_configuration: Static hosting setup  
  - aws_s3_bucket_public_access_block: Security hardening
  - aws_s3_bucket_policy: CloudFront-only access (OAC)

Security Features:
  Public access completely blocked
  CloudFront Origin Access Control (OAC)
  Least privilege bucket policies
  Encryption in transit and at rest

Inputs: bucket_name, environment, cloudfront_distribution_arn
Outputs: bucket_arn, bucket_domain_name, bucket_regional_domain_name
```

### **DynamoDB Module** - Visitor Counter Storage
```hcl
Purpose: Scalable, cost-effective visitor tracking with atomic operations
Resources:
  - aws_dynamodb_table: Pay-per-request table
  - aws_dynamodb_table_item: Initialize counter to zero

Design Decisions:
  Pay-per-request billing (cost-optimized for low traffic)
  Single-item design for atomic increments
  Lifecycle management prevents counter resets
  Environment-specific table naming

Data Model:
  Partition Key: id (String) = "visitor_count"
  Attributes: count (Number) = visitor count value

Inputs: environment, table_prefix  
Outputs: table_name, table_arn
```

### **Lambda Module** - Business Logic Layer
```hcl
Purpose: Serverless visitor counter with error handling and observability
Resources:
  - aws_lambda_function: Python 3.11 runtime
  - aws_iam_role: Lambda execution role
  - aws_iam_policy: DynamoDB read/write permissions
  - data.archive_file: Automated code packaging

Architecture Benefits:
  Zero server management overhead
  Automatic scaling to demand
  Pay-per-invocation cost model
   Built-in monitoring and logging

Security Model:
  Principle of least privilege IAM
  VPC-optional design for simplicity
  Environment variable configuration
  Structured error handling

Inputs: environment, dynamodb_table_name, dynamodb_table_arn
Outputs: function_arn, function_name, function_invoke_arn
```

### **API Gateway Module** - HTTP API Layer
```hcl
Purpose: RESTful API with automatic CORS and Lambda integration
Resources:
  - aws_apigatewayv2_api: HTTP API (cost-optimized vs REST API)
  - aws_apigatewayv2_integration: Lambda proxy integration
  - aws_apigatewayv2_route: GET /count endpoint
  - aws_apigatewayv2_stage: Production deployment stage
  - aws_lambda_permission: API Gateway invoke permissions

Technical Decisions:
  HTTP API vs REST API (60% cost reduction)
  Automatic CORS configuration
  Lambda proxy integration for flexibility
  Auto-deployment for faster iterations

Inputs: environment, lambda_function_name, lambda_invoke_arn, cors_origins
Outputs: api_url, api_id
```

### **CloudFront Module** - Global Content Delivery
```hcl
Purpose: High-performance global content delivery with security headers
Resources:
  - aws_cloudfront_distribution: Global CDN with edge locations
  - Origin Access Control (OAC): Secure S3 integration

Performance Features:
 Global edge locations for low latency
 Intelligent caching strategies
 HTTP to HTTPS redirection
 Compression and optimization

Security Features:
  Origin Access Control (modern security)
  Security headers injection
  DDoS protection via AWS Shield
  Geographic restrictions capability

Inputs: bucket_domain_name, bucket_arn
Outputs: distribution_domain_name, distribution_id, distribution_arn
```

## **Environment Management Strategy**

### **Multi-Environment Architecture**
```hcl
# Development Environment
Purpose: Feature development, testing, cost optimization
Characteristics:
  - Ephemeral deployments (auto-cleanup)
  - Relaxed security for easier debugging  
  - Cost monitoring and limits
  - Frequent deployments and rollbacks

# Production Environment  
Purpose: Live website serving real traffic
Characteristics:
  - High availability and performance
  - Enhanced security and monitoring
  - Backup and disaster recovery
  - Change approval processes
```

### **Resource Naming Convention**
```hcl
Pattern: {service}-{environment}-{identifier}
Examples:
  - cloud-resume-dev-bucket-a1b2c3
  - visitor-counter-prod-lambda
  - cloud-resume-dev-api-gateway

Benefits:
  Clear resource identification
  Environment isolation
  Easier cost tracking and management
  Automated resource discovery
```

## **Security Best Practices Implementation**

### **Defense in Depth Strategy**
```yaml
Network Layer:
  - CloudFront WAF integration capability
  - HTTPS-only communication
  - Origin Access Control (OAC)

Access Control:
  - IAM roles with least privilege
  - Resource-based policies
  - Environment-specific permissions

Data Protection:
  - Encryption in transit (HTTPS/TLS)
  - Encryption at rest (S3, DynamoDB)
  - No sensitive data in code/logs

Monitoring & Auditing:
  - CloudWatch logging enabled
  - API Gateway access logging
  - Lambda function monitoring
  - Infrastructure change tracking
```

## **Cost Optimization Strategy**

### **Service Selection Rationale**
```yaml
S3 Standard Storage: $0.023/GB/month
  - Minimal storage for static files
  - Estimated cost: $1-5/month

CloudFront: $0.085/GB data transfer
  - Free tier: 1TB/month for first year
  - Estimated cost: $5-20/month at scale

Lambda: $0.20 per 1M requests
  - Free tier: 1M requests/month
  - Estimated cost: $0-10/month

DynamoDB: $1.25 per million requests
  - Free tier: 25GB storage, 25 RCU/WCU
  - Estimated cost: $0-5/month

API Gateway HTTP: $1.00 per million requests  
  - 60% cheaper than REST API
  - Estimated cost: $0-5/month

Total Estimated Monthly Cost: $6-45/month
```

### **Cost Control Measures**
- Pay-per-use services minimize idle costs
- Automated resource cleanup in dev environments
- CloudWatch billing alerts
- Resource tagging for cost allocation
- Regular cost optimization reviews

## **Deployment Strategy**

### **GitOps Workflow**
```yaml
Development Cycle:
  1. Feature development in dev environment
  2. Automated testing and validation
  3. Pull request with Terraform plan
  4. Code review and approval
  5. Merge triggers production deployment
  6. Automated rollback on failure

Environment Promotion:
  dev → staging → production
  
Deployment Types:
  - Blue/Green for zero-downtime updates
  - Canary deployments for risk reduction
  - Feature flags for gradual rollouts
```

## **Monitoring and Observability**

### **Metrics and Logging**
```yaml
Application Metrics:
  - Visitor counter accuracy
  - API response times
  - Error rates and patterns

Infrastructure Metrics:
  - CloudFront cache hit rates
  - Lambda execution duration
  - DynamoDB throttling events

Business Metrics:
  - Website traffic patterns
  - Geographic user distribution
  - Cost per visitor trends
```

## **Engineering Best Practices Demonstrated**

### **Code Quality**
-  Modular, reusable Terraform modules
-  Comprehensive variable validation
-  Detailed resource documentation
-  Consistent naming conventions
-  Error handling and edge cases

### **Security**  
-  Principle of least privilege
-  Secure defaults configuration
-  Regular security reviews
-  Compliance with AWS Well-Architected Framework

### **Operational Excellence**
-  Infrastructure as Code (100% Terraform)
-  Automated testing and deployment
-  Monitoring and alerting
-  Documentation and knowledge sharing
-  Disaster recovery planning

### **Performance Efficiency**
-  Global content delivery via CloudFront
-  Serverless architecture for auto-scaling
-  Optimized caching strategies
-  Efficient data access patterns

### **Cost Optimization**
-  Right-sized resources for workload
-  Pay-per-use service selection
-  Automated resource lifecycle management
-  Regular cost reviews and optimization

## **Future Enhancements**

### **Planned Improvements**
- Custom domain with Route53 and ACM certificates
- Enhanced monitoring with custom CloudWatch dashboards
- CI/CD pipeline with automated testing
- Database backup and point-in-time recovery
- Multi-region deployment for disaster recovery
- Performance optimization with Lambda@Edge
- Security enhancements with AWS WAF

---

## **Getting Started**

### **Prerequisites**
- AWS Account with appropriate permissions
- Terraform >= 1.0 installed
- AWS CLI configured
- GitHub repository for CI/CD

### **Quick Deploy**
```bash
# Clone repository
git clone <repository-url>
cd cloud-resume

# Initialize Terraform
cd infra/environments/dev
terraform init

# Plan deployment
terraform plan

# Deploy infrastructure
terraform apply

# Verify deployment
curl $(terraform output -raw api_url)/count
```

This architecture demonstrates enterprise-grade infrastructure engineering with a focus on security, scalability, and cost optimization while maintaining simplicity and maintainability.