locals {
  extra_packages    = concat(local.s3_packages, local.nfs_packages)
  extra_runcmd      = concat(local.s3_runcmd, local.nfs_runcmd)
  extra_write_files = concat(local.s3_write_files, local.nfs_write_files)
}

module "harvester_vm" {
  source            = "../../../modules/harvester/virtual-machine"
  vm_prefix         = var.vm_prefix
  vm_count          = var.vm_count
  vm_namespace      = var.vm_namespace
  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password
  cpu               = var.cpu
  memory            = var.memory
  network_name      = var.network_name
  image_namespace   = var.image_namespace
  image_name        = var.image_name
  os_disk_size      = var.os_disk_size
  data_disk_size    = var.nfs_server_install ? var.nfs_data_disk_size : var.data_disk_size
  startup_script    = var.startup_script
  extra_packages    = local.extra_packages
  extra_runcmd      = local.extra_runcmd
  extra_write_files = local.extra_write_files
}
