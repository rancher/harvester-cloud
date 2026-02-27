output "public_ssh_key" {
  value = var.create_ssh_key_pair ? tls_private_key.ssh[0].public_key_openssh : null
}

output "instances_private_ip" {
  value       = aws_instance.vm.private_ip
  description = "AWS EC2 Private IP"
}

output "instances_public_ip" {
  value       = aws_eip.static_ip.public_ip
  description = "AWS EC2 Public IP"
}

output "security_group_id" {
  value = aws_security_group.sg.id
}
