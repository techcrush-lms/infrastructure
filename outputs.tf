output "shared_ec2_public_ip" {
  description = "Public IP address of the Shared Compute instance"
  value       = module.shared_ec2.public_ip
}

output "rds_proxy_endpoint" {
  description = "The endpoint of the RDS Proxy"
  value       = aws_db_proxy.main.endpoint
}

output "production_ec2_id" {
  description = "The ID of the production EC2 instance (imported)"
  value       = aws_instance.production.id
}

output "production_db_endpoint" {
  description = "The endpoint of the production RDS instance (imported)"
  value       = aws_db_instance.production.endpoint
}

output "production_db_url" {
  description = "Full connection URL (endpoint:port) for production DB"
  value       = aws_db_instance.production.endpoint
}

output "production_db_username" {
  description = "Username for production DB"
  value       = data.aws_db_instance.production.master_username
  sensitive   = true
}

output "production_db_password" {
  description = "Password for production DB"
  value       = data.aws_db_instance.production.master_username # Note: Data source won't return password, this is just to avoid undeclared vars
  sensitive   = true
}

output "ecr_repository_urls" {
  description = "The URLs of the ECR repositories"
  value       = { for k, v in aws_ecr_repository.repos : k => v.repository_url }
}

output "production_db_uri" {
  description = "Full PostgreSQL URI via RDS Proxy for Production"
  value       = "postgresql://${data.aws_db_instance.production.master_username}:${var.prod_db_password}@${aws_db_proxy.main.endpoint}:5432/${data.aws_db_instance.production.db_name != "" ? data.aws_db_instance.production.db_name : "postgres"}?sslmode=require"
  sensitive   = true
}

# --- Dev/Staging RDS Outputs ---

output "dev_db_endpoint" {
  description = "The endpoint of the development RDS instance"
  value       = module.rds_dev.db_instance_endpoint
}

output "staging_db_endpoint" {
  description = "The endpoint of the staging RDS instance"
  value       = module.rds_staging.db_instance_endpoint
}

output "dev_db_username" {
  description = "The username for the development RDS instance"
  value       = var.db_auth_username
  sensitive   = true
}

output "staging_db_username" {
  description = "The username for the staging RDS instance"
  value       = var.db_auth_username
  sensitive   = true
}

output "dev_db_url" {
  description = "Connection URL for the development DB"
  value       = module.rds_dev.db_instance_endpoint
}

output "dev_db_uri" {
  description = "Full PostgreSQL URI for the development DB"
  value       = "postgresql://${var.db_auth_username}:${var.db_auth_password}@${module.rds_dev.db_instance_endpoint}/${module.rds_dev.db_name}"
  sensitive   = true
}

output "staging_db_url" {
  description = "Connection URL via RDS Proxy for Staging"
  value       = "${aws_db_proxy.staging.endpoint}:5432"
}

output "staging_db_uri" {
  description = "Full PostgreSQL URI via RDS Proxy for Staging"
  value       = "postgresql://${var.db_auth_username}:${var.db_auth_password}@${aws_db_proxy.staging.endpoint}:5432/${module.rds_staging.db_name}?sslmode=require"
  sensitive   = true
}

output "staging_rds_proxy_endpoint" {
  description = "The endpoint of the staging RDS Proxy"
  value       = aws_db_proxy.staging.endpoint
}
