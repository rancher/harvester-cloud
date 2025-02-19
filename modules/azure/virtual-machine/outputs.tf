output "public_ssh_key" {
  value = var.create_ssh_key_pair ? tls_private_key.ssh_private_key[0].public_key_openssh : null
}

output "instances_private_ip" {
  value       = azurerm_network_interface.nic.private_ip_address
  description = "Azure Virtual Machines Private IPs"
}

output "instances_public_ip" {
  value       = azurerm_public_ip.vm_ip.*.ip_address
  description = "Azure Virtual Machines Public IPs"
}

output "vnet" {
  value = azurerm_virtual_network.vnet
}

output "network_security_group" {
  value = azurerm_network_security_group.nsg
}
