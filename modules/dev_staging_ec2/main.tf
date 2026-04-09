resource "aws_security_group" "shared_ec2" {
  name        = "${var.environment}-shared-ec2-sg"
  description = "Security Group for Shared Compute (Dev/Staging)"
  vpc_id      = var.vpc_id

  # Allow Traefik (80/443)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH Access (usually needed for debugging, but keeping it restrictive is better)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Recommendation: Restrict to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-shared-ec2-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Fetch the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "shared_compute" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.shared_ec2.id]
  associate_public_ip_address = true # EIP will override this but keeping it for completeness

  tags = {
    Name        = "${var.environment}-server"
    Environment = var.environment
  }
}

resource "aws_eip" "shared_ip" {
  domain = "vpc"

  tags = {
    Name        = "${var.environment}-eip"
    Environment = var.environment
  }
}

resource "aws_eip_association" "shared_eip_assoc" {
  instance_id   = aws_instance.shared_compute.id
  allocation_id = aws_eip.shared_ip.id
}
