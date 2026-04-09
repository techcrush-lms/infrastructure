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
  default     = "shared"
}

variable "shared_instance_type" {
  description = "Instance type for the shared EC2"
  type        = string
  default     = "t3.medium"
}
