locals {
  region               = "europe-west8"
  ssh_private_key_path = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  ssh_public_key_path  = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
  instance_type        = "n2-standard-16"
}

module "harvester_node" {
  source               = "../../../modules/google-cloud/compute-engine"
  prefix               = var.prefix
  region               = local.region
  ssh_private_key_path = local.ssh_private_key_path
  ssh_public_key_path  = local.ssh_public_key_path
  instance_type        = local.instance_type
}
