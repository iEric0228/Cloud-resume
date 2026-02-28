# ============================================================
# TEMPORARY — One-time state recovery
#
# These import blocks adopt existing AWS resources into
# Terraform state.  DELETE THIS FILE after the first
# successful `terraform apply`, then commit the deletion.
# ============================================================

# ── Random Suffixes (must be imported first — other resources depend on them) ──

import {
  to = module.s3.random_string.bucket_suffix
  id = "ockc2wxm"
}

import {
  to = module.lambda.random_string.lambda_suffix
  id = "gtl7dc"
}

import {
  to = module.cloudfront.random_string.oac_suffix
  id = "pdixiv"
}

# ── DynamoDB ─────────────────────────────────────────────────────────────────

import {
  to = module.dynamodb.aws_dynamodb_table.visitor_count
  id = "cloud-resume-visitor-count-dev"
}

# ── S3 ───────────────────────────────────────────────────────────────────────

import {
  to = module.s3.aws_s3_bucket.this
  id = "cloud-resume-dev-ockc2wxm"
}

import {
  to = module.s3.aws_s3_bucket_public_access_block.this
  id = "cloud-resume-dev-ockc2wxm"
}

import {
  to = module.s3.aws_s3_bucket_server_side_encryption_configuration.this
  id = "cloud-resume-dev-ockc2wxm"
}

import {
  to = module.s3.aws_s3_bucket_versioning.this
  id = "cloud-resume-dev-ockc2wxm"
}

import {
  to = module.s3.aws_s3_bucket_cors_configuration.this
  id = "cloud-resume-dev-ockc2wxm"
}

# ── Lambda IAM (function itself doesn't exist — will be created) ─────────────

import {
  to = module.lambda.aws_iam_role.lambda_role
  id = "cloud-resume-lambda-role-dev"
}

import {
  to = module.lambda.aws_iam_policy.lambda_dynamodb_policy
  id = "arn:aws:iam::125156866057:policy/visitor-counter-dynamodb-policy-dev-gtl7dc"
}

import {
  to = module.lambda.aws_iam_role_policy_attachment.lambda_basic_execution
  id = "cloud-resume-lambda-role-dev/arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

import {
  to = module.lambda.aws_iam_role_policy_attachment.lambda_dynamodb_policy
  id = "cloud-resume-lambda-role-dev/arn:aws:iam::125156866057:policy/visitor-counter-dynamodb-policy-dev-gtl7dc"
}

# ── CloudFront ───────────────────────────────────────────────────────────────

import {
  to = module.cloudfront.aws_cloudfront_origin_access_control.s3_oac
  id = "E2S2W53J6FNLPW"
}

import {
  to = module.cloudfront.aws_cloudfront_distribution.this
  id = "E3MBXFL0IGYN7G"
}

import {
  to = module.cloudfront.aws_s3_bucket_policy.oac_policy
  id = "cloud-resume-dev-ockc2wxm"
}

# ── ACM Certificate ──────────────────────────────────────────────────────────

import {
  to = module.acm[0].aws_acm_certificate.this
  id = "arn:aws:acm:us-east-1:125156866057:certificate/5207f4ae-53a1-41a3-892c-1817fc59bf18"
}

# ── Route 53 Records ─────────────────────────────────────────────────────────

import {
  to = module.route53[0].aws_acm_certificate_validation.this
  id = "arn:aws:acm:us-east-1:125156866057:certificate/5207f4ae-53a1-41a3-892c-1817fc59bf18"
}

import {
  to = module.route53[0].aws_route53_record.cert_validation["ericchiu.page"]
  id = "Z1031530U3NO7G1NUVPS__cc95bc9053140c7222fc4782e5d29530.ericchiu.page_CNAME"
}

import {
  to = module.route53[0].aws_route53_record.cert_validation["www.ericchiu.page"]
  id = "Z1031530U3NO7G1NUVPS__b932ce5862a473113c90b9297ab4eae4.www.ericchiu.page_CNAME"
}

import {
  to = module.route53[0].aws_route53_record.root
  id = "Z1031530U3NO7G1NUVPS_ericchiu.page_A"
}

import {
  to = module.route53[0].aws_route53_record.www
  id = "Z1031530U3NO7G1NUVPS_www.ericchiu.page_A"
}
