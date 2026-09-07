terraform {
  required_version = ">= 1.15.1, < 2.0.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "= 6.45.0" }
  }
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  default_tags { tags = { Project = "flask-learning-lab", Environment = var.environment, ManagedBy = "Terraform" } }
}
