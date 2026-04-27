# --- Production Discovery (eu-west-1) ---

data "aws_ami" "ubuntu_prod" {
  provider    = aws.prod
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data discovery for existing Production EC2
data "aws_instance" "production" {
  provider    = aws.prod
  instance_id = var.prod_instance_id
}

# Data discovery for existing Production RDS
data "aws_db_instance" "production" {
  provider               = aws.prod
  db_instance_identifier = var.prod_db_identifier
}

# Fetching Prod Subnet to get VPC ID (for RDS Proxy SG etc. in eu-west-1)
data "aws_subnet" "prod_selected" {
  provider = aws.prod
  id       = data.aws_instance.production.subnet_id
}

data "aws_vpc" "prod_selected" {
  provider = aws.prod
  id       = data.aws_subnet.prod_selected.vpc_id
}

# Fetch all subnets in the production VPC for RDS Proxy
data "aws_subnets" "prod_available" {
  provider = aws.prod
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.prod_selected.id]
  }
}

# --- Dev/Staging Discovery (us-east-1) ---

# Look up default VPC and Subnet for the Shared environment in us-east-1
data "aws_vpc" "dev_default" {
  # (No provider alias = default us-east-1)
  default = true
}

data "aws_subnets" "dev_available" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dev_default.id]
  }
}

# Select the first available subnet in us-east-1 for the shared host
data "aws_subnet" "dev_selected" {
  id = data.aws_subnets.dev_available.ids[0]
}

# Look up the current AWS account ID for use in IAM ARNs
data "aws_caller_identity" "current" {}
