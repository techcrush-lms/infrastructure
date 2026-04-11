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
  value       = "${aws_db_instance.production.endpoint}:${aws_db_instance.production.port}"
}

output "production_db_username" {
  description = "Username for production DB"
  value       = var.username
  sensitive   = true
}

output "production_db_password" {
  description = "Password for production DB"
  value       = var.password
  sensitive   = true
}

output "ecr_repository_urls" {
  description = "The URLs of the ECR repositories"
  value       = { for k, v in aws_ecr_repository.repos : k => v.repository_url }
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
  value       = module.rds_dev.db_username
  sensitive   = true
}

output "staging_db_username" {
  description = "The username for the staging RDS instance"
  value       = module.rds_staging.db_username
  sensitive   = true
}

output "staging_rds_proxy_endpoint" {
  description = "The endpoint of the staging RDS Proxy"
  value       = aws_db_proxy.staging.endpoint
}
