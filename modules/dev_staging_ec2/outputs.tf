output "public_ip" {
  value = aws_eip.shared_ip.public_ip
}

output "instance_id" {
  value = aws_instance.shared_compute.id
}
