# This file defines where Terraform stores its state
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Backend configuration (we'll add this later when we set up remote state)
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "cloud-resume/terraform.tfstate"
  #   region = "us-east-1"
  # }
}