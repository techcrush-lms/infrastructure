output "public_ip" {
  value = aws_eip.shared_ip.public_ip
}

output "instance_id" {
  value = aws_instance.shared_compute.id
}

output "security_group_id" {
  value = aws_security_group.shared_ec2.id
}
