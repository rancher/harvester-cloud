locals {
  region               = "fra1"
  ssh_private_key_path = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  ssh_public_key_path  = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
  instance_type        = "g-16vcpu-64gb-intel"
}

module "harvester_node" {
  source               = "../../../modules/digitalocean/droplet"
  prefix               = var.prefix
  region               = local.region
  ssh_private_key_path = local.ssh_private_key_path
  ssh_public_key_path  = local.ssh_public_key_path
  instance_type        = local.instance_type
}
