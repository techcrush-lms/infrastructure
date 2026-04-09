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

output "ecr_app_url" {
  description = "The URL of the App ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_proxy_url" {
  description = "The URL of the Proxy ECR repository"
  value       = aws_ecr_repository.proxy.repository_url
}
