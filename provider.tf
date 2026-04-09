terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Default provider for us-east-1 (Dev/Staging)
provider "aws" {
  region = var.dev_region
}

# Aliased provider for eu-west-1 (Production)
provider "aws" {
  alias  = "prod"
  region = var.prod_region
}
