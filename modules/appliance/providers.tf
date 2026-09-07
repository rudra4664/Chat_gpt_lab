terraform {
  required_version = ">= 1.15.1, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.45.0, < 7.0.0"
    }
  }
}
# The deployment root supplies the AWS provider configuration and credentials.
