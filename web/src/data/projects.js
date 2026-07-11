// Real project data — pulled from the résumé / prior site content, not invented.
// GitHub buttons point at the profile until per-repo URLs are added here.
const GITHUB_PROFILE = 'https://github.com/iEric0228';

export const projects = [
  {
    title: 'AI-Assisted SRE Incident Analysis System',
    tagline: 'Event-driven pipeline that triages production incidents in ~6 seconds.',
    problem:
      'Manual incident triage is slow and inconsistent under pressure — the first minutes of an outage are the most expensive.',
    description:
      'EventBridge triggers a Step Functions fan-out of three parallel collectors (metrics, logs, deploy context). Amazon Bedrock analyzes the evidence and generates an AI root-cause hypothesis. Advisory-only by design: IAM explicitly denies the analyzer any mutating action. Results land in DynamoDB (90-day TTL) and are pushed to Slack/SNS.',
    highlights: [
      'Automatically analyzes incidents and drafts an AI-powered RCA',
      'Reduces MTTR — end-to-end triage in ~6 seconds',
      '100% serverless; ARM64 Lambda + Express Step Functions keep cost near $5/mo per 100 incidents',
    ],
    tech: ['Step Functions', 'Lambda', 'Bedrock', 'Terraform', 'CloudWatch', 'EventBridge', 'SNS', 'X-Ray'],
    github: GITHUB_PROFILE,
    demo: null,
    architecture: null,
    featured: true,
  },
  {
    title: 'Enterprise 3-Tier Containerized Application',
    tagline: 'Highly available React + Node.js app on ECS Fargate, Multi-AZ end to end.',
    problem:
      'A monolithic app with no isolation between tiers and no automated deploy path — one bad release could take the whole thing down.',
    description:
      'React + Node.js + PostgreSQL (Multi-AZ) running on ECS Fargate behind an ALB, fully isolated across a 3-tier VPC. Refactored a 1,200-line monolith into 9 focused services. Full observability stack, Secrets Manager, and WAF in front of the ALB — cost-tuned with Fargate Spot and RDS auto-pause.',
    highlights: [
      'Highly available infrastructure across multiple AZs',
      'CI/CD via GitHub Actions from commit to running task',
      'Containerized, isolated 3-tier VPC with WAF at the edge',
    ],
    tech: ['Terraform', 'Docker', 'React', 'Node.js', 'ECS Fargate', 'RDS', 'ALB', 'WAF', 'GitHub Actions'],
    github: GITHUB_PROFILE,
    demo: null,
    architecture: null,
    featured: true,
  },
  {
    title: 'Aura — AI GPU Autoscaler',
    tagline: 'Ephemeral EKS clusters that scale GPU capacity to zero when idle.',
    problem:
      'GPU nodes are expensive to leave running, but provisioning them on demand for batch AI workloads is slow if done manually.',
    description:
      'Karpenter provisions GPU node pools automatically for a batch AI workload, then scales back to zero the moment the job finishes — the cluster deploys, runs, collects results, and self-destructs. GitHub Actions authenticates via OIDC, so there are zero static AWS keys anywhere in the pipeline.',
    highlights: [
      'Provisions GPU nodes automatically, on demand',
      'Scale-to-zero eliminates idle GPU cost',
      'OIDC federation — zero static AWS credentials',
    ],
    tech: ['EKS', 'Karpenter', 'Terraform', 'GitHub Actions', 'OIDC'],
    github: GITHUB_PROFILE,
    demo: null,
    architecture: null,
    featured: true,
  },
  {
    title: 'FinOps Zombie Hunter',
    tagline: 'Scheduled automation that finds and reports idle AWS spend.',
    problem:
      'Idle resources (unattached EBS volumes, orphaned NAT gateways, EIPs) quietly rack up cost across every region with no one watching.',
    description:
      'A scheduled Lambda scans every enabled region for orphaned EBS volumes, NAT Gateways, RDS instances, and Elastic IPs, and reports the waste. Dry-run by default with an explicit report-only vs. delete safety model; tfsec and flake8 gate the CI pipeline before anything ships.',
    highlights: [
      'Detects idle AWS resources across all regions',
      'Automates cost optimization with a safe, dry-run-first model',
      'Flagged ~$230/month of waste in a test account',
    ],
    tech: ['Lambda', 'Terraform', 'Python', 'SNS', 'EventBridge'],
    github: GITHUB_PROFILE,
    demo: null,
    architecture: null,
    featured: true,
  },
  {
    title: 'MCP DevOps Mentor',
    tagline: 'AI-powered assistant for Terraform auditing and IAM security review.',
    problem:
      'Reviewing Terraform plans and IAM policies by hand is slow, and it is easy to miss an overly broad permission.',
    description:
      'An MCP-based assistant that audits Terraform configurations and analyzes IAM policies for least-privilege violations, surfacing findings through a simple, queryable interface backed by the GitHub API.',
    highlights: ['Terraform auditing', 'IAM security analysis', 'AI-powered DevOps assistant'],
    tech: ['Docker', 'Python', 'SQLite', 'GitHub API'],
    github: GITHUB_PROFILE,
    demo: null,
    architecture: null,
    featured: true,
  },
];
