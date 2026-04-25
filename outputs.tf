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

# --- Dev/Staging RDS Outputs (Removed) ---


output "monitoring_ec2_public_ip" {
  description = "Public IP address of the Monitoring instance"
  value       = module.monitoring_ec2.public_ip
}

output "monitoring_iam_role_arn" {
  description = "The ARN of the IAM role attached to the Monitoring instance"
  value       = module.monitoring_ec2.iam_role_arn
}

output "bastion_public_ip" {
  description = "Public IP address of the unified Monitoring/Bastion host"
  value       = module.monitoring_ec2.public_ip
}

output "rds_ssh_tunnel_command" {
  description = "Command to create an SSH tunnel to the production RDS instance"
  value       = "ssh -L 5432:${data.aws_db_instance.production.address}:5432 ubuntu@${module.monitoring_ec2.public_ip}"
}

output "dev_vpc_cidr" {
  value = data.aws_vpc.dev_default.cidr_block
}

output "prod_vpc_cidr" {
  value = data.aws_vpc.prod_selected.cidr_block
}
