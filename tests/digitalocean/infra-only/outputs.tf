output "first_instance_public_ip" {
  value = module.harvester_node.instances_public_ip[0]
}
