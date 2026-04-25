variable "prod_region" {
  description = "AWS region for Production"
  type        = string
  default     = "eu-west-1"
}

variable "dev_region" {
  description = "AWS region for Dev/Staging"
  type        = string
  default     = "us-east-1"
}

variable "prod_instance_id" {
  description = "The ID of the existing production EC2 instance"
  type        = string
}

variable "prod_db_identifier" {
  description = "The identifier of the existing production RDS instance"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev-staging"
}

variable "shared_instance_type" {
  description = "Instance type for the shared EC2"
  type        = string
  default     = "t3.medium"
}

variable "db_auth_username" {
  description = "Username for the Dev/Staging RDS instances"
  type        = string
  default     = "admin"
}

variable "db_auth_password" {
  description = "Password for the Dev/Staging RDS instances"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_auth_password) >= 8 && !can(regex("[/@\"]", var.db_auth_password))
    error_message = "The password must be at least 8 characters long and cannot contain '/', '@', or '\"'."
  }
}

variable "prod_db_password" {
  description = "Password for the Production RDS instance"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.prod_db_password) >= 8 && !can(regex("[/@\"]", var.prod_db_password))
    error_message = "The password must be at least 8 characters long and cannot contain '/', '@', or '\"'."
  }
}

variable "db_whitelist_cidr" {
  description = "CIDR block to whitelist for database access (e.g. your local IP)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "bastion_public_key" {
  description = "The public SSH key for the bastion host"
  type        = string
}
