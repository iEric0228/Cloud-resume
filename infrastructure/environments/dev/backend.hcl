bucket         = "ericchiu-terraform-state"
key            = "cloud-resume/dev/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-state-lock"
