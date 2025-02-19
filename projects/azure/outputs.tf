output "first_instance_private_ip" {
  value = module.harvester_node.instances_private_ip
}

output "first_instance_public_ip" {
  value = module.harvester_node.instances_public_ip
}

output "harvester_url" {
  value = "https://${var.prefix}.${module.harvester_node.instances_public_ip[0]}.sslip.io"
}

output "longhorn_url" {
  value = "https://${var.prefix}.${module.harvester_node.instances_public_ip[0]}.sslip.io/dashboard/c/local/longhorn"
}