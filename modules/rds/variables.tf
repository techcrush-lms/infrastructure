variable "environment" {
  description = "Deployment environment (dev or staging)"
  type        = string
}

variable "instance_identifier" {
  description = "RDS instance identifier"
  type        = string
  default     = null
}

variable "engine" {
  description = "Database engine (e.g., postgres, mysql)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "15"
}

variable "instance_class" {
  description = "Instance class, smallest possible for dev/staging"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB (minimum)"
  type        = number
  default     = 20
}

variable "username" {
  description = "Master username for the DB"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Master password for the DB"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot on destroy"
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Make the DB publicly accessible (useful for dev)"
  type        = bool
  default     = true
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs for the DB"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
  default     = []
}
