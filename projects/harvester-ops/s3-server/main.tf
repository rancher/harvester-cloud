locals {
  s3_setup_script = base64encode(templatefile("${path.module}/../../../modules/harvester/workload-scripts/s3-garage-setup.sh.tpl", {
    garage_version = var.s3_garage_version
    bucket_name    = var.s3_bucket_name
    bucket_region  = var.s3_bucket_region
  }))
}

module "harvester_vm" {
  source          = "../../../modules/harvester/virtual-machine"
  vm_prefix       = var.vm_prefix
  vm_count        = var.vm_count
  vm_namespace    = var.vm_namespace
  ssh_username    = var.ssh_username
  ssh_password    = var.ssh_password
  cpu             = var.cpu
  memory          = var.memory
  network_name    = var.network_name
  image_namespace = var.image_namespace
  image_name      = var.image_name
  os_disk_size    = var.os_disk_size
  data_disk_size  = var.data_disk_size
  extra_packages  = ["wget", "openssl"]
  extra_runcmd    = ["sleep 60 && bash /opt/s3-garage-setup.sh > /var/log/s3-garage-setup.log 2>&1"]
  extra_write_files = [
    {
      path        = "/opt/s3-garage-setup.sh"
      permissions = "0755"
      encoding    = "b64"
      content     = local.s3_setup_script
    }
  ]
}
