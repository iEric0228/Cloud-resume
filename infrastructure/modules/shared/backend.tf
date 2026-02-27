# ============================================================
# Shared Backend Reference
#
# This file documents the IAM permissions required for the
# GitHub Actions OIDC role to access Terraform remote state.
#
# Add the following policy to your GitHub Actions IAM role
# AFTER running infrastructure/bootstrap:
# ============================================================

# Required IAM policy statement (add to your OIDC role):
#
# {
#   "Effect": "Allow",
#   "Action": [
#     "s3:GetObject",
#     "s3:PutObject",
#     "s3:DeleteObject",
#     "s3:ListBucket"
#   ],
#   "Resource": [
#     "arn:aws:s3:::cloud-resume-tfstate-<ACCOUNT_ID>",
#     "arn:aws:s3:::cloud-resume-tfstate-<ACCOUNT_ID>/*"
#   ]
# },
# {
#   "Effect": "Allow",
#   "Action": [
#     "dynamodb:GetItem",
#     "dynamodb:PutItem",
#     "dynamodb:DeleteItem"
#   ],
#   "Resource": "arn:aws:dynamodb:us-east-1:<ACCOUNT_ID>:table/cloud-resume-tfstate-lock"
# }
#
# The bootstrap module outputs the exact bucket name to use above.
