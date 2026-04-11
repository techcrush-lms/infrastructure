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
  value       = data.aws_db_instance.production.master_username
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
