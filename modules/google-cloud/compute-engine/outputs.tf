output "public_ssh_key" {
  value = var.create_ssh_key_pair ? tls_private_key.ssh_private_key[0].public_key_openssh : null
}

output "instances_private_ip" {
  value       = google_compute_instance.default.*.network_interface.0.network_ip
  description = "Google Compute Engine Intances Private IPs"
}

output "instances_public_ip" {
  value       = google_compute_instance.default.*.network_interface.0.access_config.0.nat_ip
  description = "Google Compute Engine Intances Public IPs"
}

output "instance_ips" {
  value = [
    for i in google_compute_instance.default.*.network_interface.0 :
    {
      public_ip  = i.access_config.0.nat_ip
      private_ip = i.network_ip
    }
  ]
}

output "vpc" {
  value = google_compute_network.vpc
}

output "subnet" {
  value = google_compute_subnetwork.subnet
}

output "firewall" {
  value = google_compute_firewall.cluster_plane
}
