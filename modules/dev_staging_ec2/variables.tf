variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the instance will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be created"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "architecture" {
  description = "Instance architecture (amd64 or arm64)"
  type        = string
  default     = "amd64"
}
