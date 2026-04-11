output "db_instance_endpoint" {
  description = "Endpoint address of the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.this.port
}

output "db_instance_identifier" {
  description = "Identifier of the RDS instance"
  value       = aws_db_instance.this.identifier
}

output "db_instance_url" {
  description = "Full connection URL (endpoint:port)"
  value       = "${aws_db_instance.this.endpoint}:${aws_db_instance.this.port}"
}

output "db_username" {
  description = "Username for the RDS instance"
  value       = var.username
  sensitive   = true
}

output "db_password" {
  description = "Password for the RDS instance"
  value       = var.password
  sensitive   = true
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = aws_db_instance.this.resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = aws_db_instance.this.status
}
