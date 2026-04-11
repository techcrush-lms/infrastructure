resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-rds-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier             = var.instance_identifier != null ? var.instance_identifier : "${var.environment}-rds"
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  skip_final_snapshot    = var.skip_final_snapshot
  publicly_accessible    = var.publicly_accessible
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.this.name
  apply_immediately      = true

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-rds"
  }
}
