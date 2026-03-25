output "first_instance_private_ip" {
  value = module.harvester_node.instances_private_ip
}

output "first_instance_public_ip" {
  value = module.harvester_node.instances_public_ip
}
