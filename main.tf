# --- Production Infrastructure (eu-west-1) ---

# Modern Import Blocks
import {
  to       = aws_instance.production
  id       = var.prod_instance_id
  provider = aws.prod
}

import {
  to       = aws_db_instance.production
  id       = var.prod_db_identifier
  provider = aws.prod
}

resource "aws_instance" "production" {
  provider      = aws.prod
  ami           = data.aws_instance.production.ami
  instance_type = data.aws_instance.production.instance_type # Using the discovered instance type

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }

  tags = data.aws_instance.production.tags
}

resource "aws_db_instance" "production" {
  provider             = aws.prod
  instance_class       = data.aws_db_instance.production.db_instance_class
  engine               = data.aws_db_instance.production.engine
  identifier           = var.prod_db_identifier
  allocated_storage    = data.aws_db_instance.production.allocated_storage
  db_name              = data.aws_db_instance.production.db_name
  username             = data.aws_db_instance.production.master_username
  db_subnet_group_name = data.aws_db_instance.production.db_subnet_group

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }

  tags = data.aws_db_instance.production.tags
}

# RDS Proxy Implementation (Must be in the same region as RDS - eu-west-1)
resource "aws_db_proxy" "main" {
  provider               = aws.prod
  name                   = "${var.prod_db_identifier}-proxy"
  debug_logging          = false
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_security_group_ids = [aws_security_group.rds_proxy.id]
  vpc_subnet_ids         = data.aws_subnets.prod_available.ids

  auth {
    auth_scheme = "SECRETS"
    description = "RDS Proxy Auth"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.db_credentials.arn
  }
}

resource "aws_db_proxy_default_target_group" "main" {
  provider      = aws.prod
  db_proxy_name = aws_db_proxy.main.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 100
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "main" {
  provider               = aws.prod
  db_instance_identifier = var.prod_db_identifier
  db_proxy_name          = aws_db_proxy.main.name
  target_group_name      = aws_db_proxy_default_target_group.main.name
}

resource "aws_iam_role" "rds_proxy" {
  provider = aws.prod # IAM is global but provider helps with metadata if needed
  name     = "rds-proxy-role-${var.prod_db_identifier}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_security_group" "rds_proxy" {
  provider = aws.prod
  name     = "rds-proxy-sg"
  vpc_id   = data.aws_vpc.prod_selected.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.prod_selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_secretsmanager_secret" "db_credentials" {
  provider = aws.prod
  name     = "db-credentials-${var.prod_db_identifier}"
}

# --- Dev/Staging Infrastructure (us-east-1) ---

module "shared_ec2" {
  # Default provider (us-east-1) is used here
  source = "./modules/dev_staging_ec2"

  environment   = var.environment
  vpc_id        = data.aws_vpc.dev_default.id
  subnet_id     = data.aws_subnet.dev_selected.id
  instance_type = var.shared_instance_type
}

# --- ECR Repositories (us-east-1) ---

# --- ECR Repositories (us-east-1) ---

locals {
  ecr_repositories = [
    "frontend-dev",
    "backend-dev",
    "frontend-staging",
    "backend-staging"
  ]
}

resource "aws_ecr_repository" "repos" {
  for_each             = toset(local.ecr_repositories)
  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# --- Dev/Staging RDS Infrastructure (us-east-1) ---

resource "aws_security_group" "dev_staging_rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for Dev and Staging RDS"
  vpc_id      = data.aws_vpc.dev_default.id

  # Allow direct traffic from EC2 for Dev RDS
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.shared_ec2.security_group_id]
  }

  # Allow traffic from Staging RDS Proxy
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.staging_rds_proxy.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-rds-sg"
  }
}

# --- Staging RDS Proxy (us-east-1) ---

resource "aws_secretsmanager_secret" "staging_db_credentials" {
  name = "staging-db-credentials-${module.rds_staging.db_instance_identifier}"
}

resource "aws_secretsmanager_secret_version" "staging_db_credentials" {
  secret_id = aws_secretsmanager_secret.staging_db_credentials.id
  secret_string = jsonencode({
    username = var.db_auth_username
    password = var.db_auth_password
  })
}

resource "aws_iam_role" "staging_rds_proxy" {
  name = "staging-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "staging_rds_proxy" {
  name = "staging-rds-proxy-policy"
  role = aws_iam_role.staging_rds_proxy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = [aws_secretsmanager_secret.staging_db_credentials.arn]
      }
    ]
  })
}

resource "aws_security_group" "staging_rds_proxy" {
  name        = "staging-rds-proxy-sg"
  description = "Security group for Staging RDS Proxy"
  vpc_id      = data.aws_vpc.dev_default.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.shared_ec2.security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "staging"
    Name        = "staging-rds-proxy-sg"
  }
}

resource "aws_db_proxy" "staging" {
  name                   = "staging-rds-proxy"
  debug_logging          = false
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.staging_rds_proxy.arn
  vpc_security_group_ids = [aws_security_group.staging_rds_proxy.id]
  vpc_subnet_ids         = data.aws_subnets.dev_available.ids

  auth {
    auth_scheme = "SECRETS"
    description = "Staging RDS Proxy Auth"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.staging_db_credentials.arn
  }

  tags = {
    Environment = "staging"
    Name        = "staging-rds-proxy"
  }
}

resource "aws_db_proxy_default_target_group" "staging" {
  db_proxy_name = aws_db_proxy.staging.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 100
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "staging" {
  db_instance_identifier = module.rds_staging.db_instance_identifier
  db_proxy_name          = aws_db_proxy.staging.name
  target_group_name      = aws_db_proxy_default_target_group.staging.name
}

module "rds_dev" {
  source = "./modules/rds"

  environment            = "dev"
  instance_identifier    = "dev-rds"
  vpc_security_group_ids = [aws_security_group.dev_staging_rds.id]
  subnet_ids             = data.aws_subnets.dev_available.ids
  username               = var.db_auth_username
  password               = var.db_auth_password
}

module "rds_staging" {
  source = "./modules/rds"

  environment            = "staging"
  instance_identifier    = "staging-rds"
  vpc_security_group_ids = [aws_security_group.dev_staging_rds.id]
  subnet_ids             = data.aws_subnets.dev_available.ids
  username               = var.db_auth_username
  password               = var.db_auth_password
}
