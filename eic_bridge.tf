resource "aws_security_group_rule" "ec2_allow_eic_ssh" {
  provider                 = aws.prod
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eic_endpoint.id
  security_group_id        = tolist(data.aws_instance.production.vpc_security_group_ids)[0]
  description              = "Allow SSH from EC2 Instance Connect Endpoint"
}
